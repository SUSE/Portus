class DashboardController < ApplicationController

  def index
     @activities = policy_scope(PublicActivity::Activity)
  end

end
