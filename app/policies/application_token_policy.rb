# frozen_string_literal: true

class ApplicationTokenPolicy
  attr_reader :user, :application_token

  def initialize(user, application_token)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @application_token = application_token
  end

  def destroy?
    user.id == application_token.user_id ||
      user.admin? && application_token.user.bot
  end
end
