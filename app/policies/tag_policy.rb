# frozen_string_literal: true

# Defines the policy for the tag object.
class TagPolicy
  attr_reader :user, :tag

  def initialize(user, tag)
    @user = user
    @tag = tag
  end

  def show?
    @user.admin? ||
      @tag.repository.namespace.visibility_public? ||
      @tag.repository.namespace.visibility_protected? ||
      @tag.repository.namespace.team.users.exists?(user.id)
  end

  # Returns true if the tag can be destroyed.
  def destroy?
    RepositoryPolicy.new(user, tag.repository).destroy?
  end
end
