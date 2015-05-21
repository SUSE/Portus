class SearchController < ApplicationController
  def index
    @repositories = policy_scope(Repository).search(params[:search])
  end
end
