class SearchController < ApplicationController
  def index
    search = params[:search].split(':').first
    @repositories = policy_scope(Repository).search(search)
  end
end
