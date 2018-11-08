# frozen_string_literal: true

# == Schema Information
#
# Table name: application_tokens
#
#  id          :integer          not null, primary key
#  application :string(255)      not null
#  token_hash  :string(255)      not null
#  token_salt  :string(255)      not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_application_tokens_on_user_id  (user_id)
#

class ApplicationToken < ApplicationRecord
  include PublicActivity::Common

  belongs_to :user

  validates :application, uniqueness: { scope: "user_id" }
  validate :limit_number_of_tokens_per_user, on: :create

  def limit_number_of_tokens_per_user
    max_reached = User.find(user_id).application_tokens.count >= User::APPLICATION_TOKENS_MAX
    return unless max_reached

    errors.add(:base, "Users cannot have more than #{User::APPLICATION_TOKENS_MAX} " \
      "application tokens")
  end

  # Create the activity regarding this application token.
  def create_activity!(type, owner)
    create_activity(
      type,
      owner:      owner,
      parameters: { application: application }
    )
  end

  class << self
    # Create new application token and generate plain token, salt, nash.
    # If user_id passed then created token belongs to the user.
    #
    # Return array with application_token and plain_token.
    def create_token(current_user:, user_id: nil, params:)
      plain_token = Devise.friendly_token

      application_token = ApplicationToken.new params
      application_token.user_id = user_id || current_user.id
      application_token.token_salt = BCrypt::Engine.generate_salt
      application_token.token_hash = BCrypt::Engine.hash_secret(
        plain_token,
        application_token.token_salt
      )
      application_token.create_activity!(:create, current_user) if application_token.save

      [application_token, plain_token]
    end
  end
end
