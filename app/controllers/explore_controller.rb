# ExploreController exposes a search interface for non-logged in (anonymous)
# users. It allows these users to search for public repositories.
class ExploreController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :feature_enabled, only: [:index]

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :deny_access

  layout "authentication"

  # It's both the main page and the page where search results are shown.
  def index
    @current = search_params

    if @current
      repository    = @current.split(":").first
      @repositories = policy_scope(Repository).search(repository)
    else
      @repositories = []
    end
  end

  protected

  # Returns a string with the search query, or nil if none was given.
  def search_params
    s = params.permit(explore: [:search])
    return unless s[:explore]
    s[:explore][:search]
  end

  # Redirect to the root page if this feature is not enabled.
  def feature_enabled
    redirect_to root_path unless APP_CONFIG.enabled?("anonymous_browsing")
  end
end
