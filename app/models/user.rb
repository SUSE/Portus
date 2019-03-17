# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  username               :string(255)      default(""), not null
#  email                  :string(255)      default("")
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  admin                  :boolean          default(FALSE)
#  enabled                :boolean          default(TRUE)
#  ldap_name              :string(255)
#  failed_attempts        :integer          default(0)
#  locked_at              :datetime
#  namespace_id           :integer
#  display_name           :string(255)
#  provider               :string(255)
#  uid                    :string(255)
#  bot                    :boolean          default(FALSE)
#  ldap_group_checked     :integer          default(0)
#
# Indexes
#
#  index_users_on_display_name          (display_name) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_namespace_id          (namespace_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#

class User < ApplicationRecord
  include PublicActivity::Common

  enum ldap_status: { unchecked: 0, checked: 1, disabled: 2 }

  enabled_devise_modules = [:database_authenticatable, :registerable, :lockable,
                            :recoverable, :rememberable, :trackable, :validatable,
                            :omniauthable,
                            omniauth_providers:  %i[
                              google_oauth2
                              open_id
                              openid_connect
                              github
                              gitlab
                              bitbucket
                            ],
                            authentication_keys: [:username]]

  enabled_devise_modules.delete(:validatable) if APP_CONFIG.enabled?("ldap")
  devise(*enabled_devise_modules)

  APPLICATION_TOKENS_MAX = 5

  # Actions performed before/after create.
  validates :username, presence: true, uniqueness: true
  validates :password, confirmation: true
  validate :private_namespace_and_team_available, on: :create
  validate :portus_user_validation, on: :update
  after_create :create_personal_namespace!, if: :needs_namespace?
  after_create :no_skip_validation!

  # Actions performed before destroy
  before_destroy :update_tags!

  belongs_to :namespace
  has_many :team_users, dependent: :destroy
  has_many :teams, through: :team_users
  has_many :stars, dependent: :destroy
  has_many :application_tokens, dependent: :destroy
  has_many :tags, dependent: :nullify
  has_many :comments, dependent: :destroy

  scope :not_portus, -> { where.not(username: "portus") }
  scope :enabled,    -> { not_portus.where(enabled: true) }
  scope :admins,     -> { not_portus.where(enabled: true, admin: true) }

  class <<self
    attr_accessor :skip_portus_validation
  end

  # Creates the Portus hidden user.
  def self.create_portus_user!
    User.skip_portus_validation = true
    User.create!(
      username: "portus",
      password: Rails.application.secrets.portus_password,
      email:    "portus@portus.com",
      admin:    true
    )
  end

  # Returns portus user
  def self.portus
    find_by(username: "portus")
  end

  # Creates a user and sets this password as an empty string. This way we don't
  # store sensible data that is already stored in another place (e.g. LDAP), and
  # regular login won't be allowed for such users. The `params` argument is the
  # parameters that will be passed into the `User.create` method call.
  #
  # Returns two objects: a user object, and a boolean stating whether everything
  # was ok or not. Callers should check this second object before doing anything
  # at all with the first (since it might be an invalid user object).
  def self.create_without_password(params)
    user    = nil
    created = false

    ActiveRecord::Base.transaction do
      # We create it first with a dummy password that will be erased later on.
      user = User.create(params.merge(password: SecureRandom.hex(16)))

      if user.persisted?
        created = user.update(encrypted_password: "")
        user.destroy unless created
      end
    end
    [user, created]
  end

  # Returns true this user is allowed to login, otherwise it returns
  # false. Right now, only users that were created from LDAP cannot login
  # outside of the LDAP context.
  def login_allowed?
    return true if APP_CONFIG.enabled?("ldap")

    encrypted_password != ""
  end

  # Special method used by Devise to require an email on signup. This is always
  # true except for LDAP.
  def email_required?
    !(APP_CONFIG.enabled?("ldap") && email.blank?)
  end

  # Adds an error if the user to be updated is the portus one. This is a
  # validation on update, so it can be skipped when strictly required.
  def portus_user_validation
    # If nothing really changed (e.g. Rails simply touched this record), then we
    # can leave early.
    return if saved_changes.keys.empty?

    # If validation for this was temporarily disabled (e.g. we are creating the
    # Portus hidden user for the first time), then enable it back but return
    # early.
    if User.skip_portus_validation
      User.skip_portus_validation = nil
      return
    end

    return unless portus? || portus?(username_before_last_save)

    errors.add(:username, "cannot be updated")
  end

  # It adds an error if the username clashes with either a namespace or a team.
  def private_namespace_and_team_available
    ns = Namespace.make_valid(username)
    return if ns

    errors.add(:username, "'#{username}' cannot be transformed into a valid namespace name")
  end

  # Returns true if the current user is the Portus user. You can provide a value
  # as an alternative to the value of `username`.
  def portus?(field = nil)
    f = field.nil? ? username : field
    f == "portus"
  end

  # Returns avatar url if gravatar is enabled and email not blank
  def avatar_url
    GravatarImageTag.gravatar_url(email) if APP_CONFIG.enabled?("gravatar") && email.present?
  end

  # Returns the username to be displayed.
  def display_username
    return username unless APP_CONFIG.enabled?("display_name")

    display_name.presence || username
  end

  # This method will be called automatically once a user is created. It will
  # also be created for each user of the system when a registry is saved in the
  # system.
  def create_personal_namespace!
    return unless needs_namespace?

    namespace_name = Namespace.make_valid(username)
    team_name = Team.make_valid(username)

    # Note that this shouldn't be a problem since the User controller will make
    # sure that we don't create a user that clashes with this team.
    team = Team.create!(name: team_name, owners: [self], hidden: true)

    default_description = "This personal namespace belongs to #{username}."
    namespace = Namespace.find_or_create_by!(
      team:        team,
      name:        namespace_name,
      visibility:  Namespace.visibilities[:visibility_private],
      description: default_description,
      registry:    Registry.get # TODO: fix once we handle more registries
    )

    # Skipping validation on purpose, so after creating the portus hidden user,
    # a namespace can be assigned to it even if updates are forbidden
    # afterwards.
    update_attribute("namespace", namespace)
  end

  # Find the user that can be guessed from the given push event.
  def self.find_from_event(event)
    actor = User.find_by(username: event["actor"]["name"])
    logger.error "Cannot find user #{event["actor"]["name"]}" if actor.nil?
    actor
  end

  # Toggle the 'admin' attribute for this user. It will also update the
  # registry accordingly.
  def toggle_admin!
    admin = !admin?
    return unless update(admin: admin) && Registry.any?

    # TODO: fix once we handle more registries
    team = Registry.get.global_namespace.team
    admin ? team.owners << self : team.owners.delete(self)
  end

  ##
  # Enabling/disabling users.

  # Toggle the enabled attribute for a user. This is an instance method because
  # it is a user that enables/disables another user.
  def toggle_enabled!(user)
    enabled = user.enabled?

    # Return false if the action is not allowed.
    return false if enabled && !can_disable?(user)
    return false if !enabled && !admin?

    user.update(enabled: !enabled)
  end

  # This method is picked up by Devise before signing in a user.
  def active_for_authentication?
    super && enabled? && login_allowed?
  end

  # The flashy message to be shown for disabled users that try to login.
  def inactive_message
    if login_allowed?
      "Sorry, this account has been disabled."
    else
      "This user can only login through an LDAP server."
    end
  end

  # Returns all users who match the query.
  def self.search_from_query(members, query)
    enabled.where.not(id: members).where(arel_table[:username].matches(query))
  end

  # Looks for an application token that matches with the plain one provided
  # as parameter.
  # Return true if there's an application token matching it, false otherwise
  def application_token_valid?(plain_token)
    application_tokens.each do |t|
      return true if t.token_hash == BCrypt::Engine.hash_secret(plain_token, t.token_salt)
    end

    false
  end

  # Update the tags owned by this user before this user gets destroyed.
  def update_tags!
    Tag.where(user_id: id).update_all(user_id: nil, username: username)
  end

  # Update the activities owned by this user. This method should only be called
  # before destroying this user.
  def update_activities!(owner)
    # Originally this was handled in a single query, but with that is was not
    # possible to fix a bug as specified in PR #1144. Now it's handled in a
    # block that ends up performing multiple queries, which we want to perform
    # atomically (thus the transaction).
    ApplicationRecord.transaction do
      PublicActivity::Activity.where(owner_id: id).find_each do |a|
        a.owner_id   = nil
        a.owner_type = nil
        a.parameters = a.parameters.merge(owner_name: display_username)
        a.save
      end
    end

    create_activity :delete,
                    owner:      owner,
                    parameters: { username: username }
  end

  # Create user form params and omniauth data.
  #   params - hash with :username and :display_name
  #   data   - hash from oauth provider. We use info: {:email}, :provider and :uid.
  def self.create_from_oauth(params, data)
    params.merge! data["info"].slice("email")
    params.merge! data.slice("provider", "uid")
    params[:password] = Devise.friendly_token[0, 20]
    User.create params
  end

  # Suggest username based on nickname for GitHub or username for GitLab.
  # For prlviders which doesn't supply username suggestion is based on left
  # side of user's email.
  # If username exists then try variant username + "_nn".
  def suggest_username(data)
    self.username = extract_username data
    user = User.find_by(username: username)
    return if user.nil?

    num = 1
    while user && num < 999
      suggest_username = "#{username}_#{num.to_s.rjust(2, "0")}"
      user = User.find_by(username: suggest_username)
      num += 1
    end
    self.username = suggest_username unless user
  end

  # Checks memberships for this user on LDAP groups and tries to add this same
  # user into existing teams as a member.
  def ldap_add_as_member!
    Rails.logger.tagged(:ldap) do
      Rails.logger.info "Looking up an LDAP group membership for '#{username}'"
    end

    portus_user = User.portus

    ::Portus::LDAP::Search.new.user_groups(username).each do |group|
      t = Team.find_by(name: group)
      next if t.nil?
      next if t.ldap_group_checked == Team.ldap_statuses[:disabled]
      next if t.users.map(&:id).include?(id)

      t.add_team_member!(portus_user, username)
    end

    update!(ldap_group_checked: User.ldap_statuses[:checked])
  end

  protected

  # Validations can no longer be skipped after calling this method.
  def no_skip_validation!
    User.skip_portus_validation = nil
  end

  # Returns true if the current user needs a namespace. This is not the case in
  # the following situations:
  #   1. A registry has not been created yet.
  #   2. A namespace has already been created for this user.
  #   3. It's not a regular user, but a bot.
  def needs_namespace?
    Registry.any? && namespace_id.nil? && !bot
  end

  # Get username from provider's data.
  def extract_username(data)
    data["nickname"] || data["username"] || data["email"]&.match(/^[^@]*/).to_s
  end

  # Returns whether the given user can be disabled or not. The following rules
  # apply:
  #   1. A user can disable himself unless it's the last admin on the system.
  #   2. The admin user is the only one that can disable other users.
  def can_disable?(user)
    # The "portus" user can never be disabled.
    return false if user.portus?

    if self == user
      # An admin cannot disable himself if he's the only admin in the system.
      # Otherwise, regular users can disable themselves.
      return true unless admin?

      User.admins.count > 1
    else
      # Only admin users can disable other users.
      admin?
    end
  end
end
