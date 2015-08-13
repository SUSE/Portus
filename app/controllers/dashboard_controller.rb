class DashboardController < ApplicationController
  def index
    @recent_activities = policy_scope(PublicActivity::Activity)
      .limit(20)
      .order("created_at desc")
    @stars = current_user.stars.order("updated_at desc")
  end
end
