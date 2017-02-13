class SearchController < ApplicationController
  def index
    search = params[:search].split(":").first
    @search_query = params[:search]
    @search_type = params[:type]

    @repositories = policy_scope(Repository).search(search).page(params[:page])
    @teams = policy_scope(Team).search(search).page(params[:page])
    @namespaces = policy_scope(Namespace).search(search).page(params[:page])
  end
end
