class ApplicationToken < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :user

  validates :application, uniqueness: { scope: "user_id" }

  validate :limit_number_of_tokens_per_user, on: :create

  def limit_number_of_tokens_per_user
    max_reached =  ApplicationToken.where(user_id: user_id).count >= User::APPLICATION_TOKENS_MAX
    errors.add(
      :base,
      "Users cannot have more than #{User::APPLICATION_TOKENS_MAX} " \
      "application tokens") if max_reached
  end

  # Create the activity regarding this application token.
  def create_activity!(type, owner)
    create_activity(
      type,
      owner:      owner,
      parameters: { application: application })
  end
end
