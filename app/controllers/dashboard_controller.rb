class DashboardController < ApplicationController
  def index
    @recent_activities = policy_scope(PublicActivity::Activity)
      .limit(20)
      .order("created_at desc")
    @repositories = policy_scope(Repository)
    @personal_repositories = Namespace.find_by(name: current_user.username).repositories
    @stars = current_user.stars.order("updated_at desc")
  end
end
