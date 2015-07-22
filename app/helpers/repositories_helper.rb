module RepositoriesHelper
  def can_star_repository?(repository)
    !repository.starred_by? current_user
  end
end
