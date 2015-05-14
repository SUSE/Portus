class Admin::DashboardController < Admin::BaseController
  def index
    @recent_activities = PublicActivity::Activity
      .where('created_at >= ?', 24.hours.ago)
      .order('created_at DESC')
  end
end
