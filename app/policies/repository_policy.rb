class RepositoryPolicy
  attr_reader :user, :repository

  def initialize(user, repository)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user
    @user = user
    @repository = repository
  end

  def pull?
    user == (repository.team.owner)
  end

  def push?
    pull?
  end

end
