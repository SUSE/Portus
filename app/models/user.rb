class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, authentication_keys: [:username]

  USERNAME_CHARS  = "a-z0-9"
  USERNAME_FORMAT = /\A[#{USERNAME_CHARS}]{4,30}\Z/

  validates :username, presence: true, uniqueness: true,
    format: {
      with:    USERNAME_FORMAT,
      message: "Only alphanumeric characters are allowed. Minimum 4 characters, maximum 30."
    }
  validate :private_namespace_available, on: :create

  has_many :team_users
  has_many :teams, through: :team_users
  has_many :stars

  scope :not_portus, -> { where.not username: "portus" }
  scope :enabled,    -> { not_portus.where enabled: true }
  scope :admins,     -> { not_portus.where enabled: true, admin: true }

  # Special method used by Devise to require an email on signup. This is always
  # true except for LDAP.
  def email_required?
    !(Portus::LDAP.enabled? && !ldap_name.nil?)
  end

  def private_namespace_available
    return unless Namespace.exists?(name: username)
    errors.add(:username, "cannot be used as name for private namespace")
  end

  # Returns true if the current user is the Portus user.
  def portus?
    username == "portus"
  end

  def create_personal_namespace!
    # the registry is not configured yet, we cannot create the namespace
    return unless Registry.any?

    team = Team.find_by(name: username)
    if team.nil?
      team = Team.create!(name: username, owners: [self], hidden: true)
    end

    Namespace.find_or_create_by!(
      team:     team,
      name:     username,
      registry: Registry.last # TODO: fix once we handle more registries
    )
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
    return unless update_attributes(admin: admin) && Registry.any?

    team = Registry.first.global_namespace.team
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

    user.update_attributes(enabled: !enabled)
  end

  # This method is picked up by Devise before signing in a user.
  def active_for_authentication?
    super && enabled?
  end

  # The flashy message to be shown for disabled users that try to login.
  def inactive_message
    "Sorry, this account has been disabled."
  end

  protected

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
