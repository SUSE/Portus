class SearchController < ApplicationController
  def index
    search = params[:search].split(":").first
    @search_query = params[:search]
    @search_type = params[:type]

    repositories = policy_scope(Repository).search(search)
    @repositories = repositories.page(params[:page]).per(2)
    @repositories_count = repositories.count()

    teams = policy_scope(Team).search(search)
    @teams = teams.page(params[:page]).per(2)
    @teams_count = teams.count()

    namespaces = policy_scope(Namespace).search(search)
    @namespaces = namespaces.page(params[:page]).per(2)
    @namespaces_count = namespaces.count()
  end
end
