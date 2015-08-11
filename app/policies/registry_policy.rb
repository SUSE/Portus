# RegistryPolicy implements the authorization policy for methods inside the
# "registry" type.
class RegistryPolicy
  attr_reader :user

  def initialize(user, _)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
  end

  # This method defines the permissions for the following scope string
  # "registry:catalog:*". Only the "portus" special user is allowed to perform
  # this call.
  def all?
    user.username == "portus"
  end
end
