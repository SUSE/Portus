# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @recent_activities = policy_scope(PublicActivity::Activity)
                         .limit(20)
                         .order(id: :desc)
    if current_user.admin?
      @admin_recent_activities = PublicActivity::Activity
                                 .order(created_at: :desc)
                                 .limit(20)
    end
    @repositories = policy_scope(Repository)
    @portus_exists = User.where(username: "portus").any?

    # The personal namespace could not exist, that happens when portus
    # does not have a registry associated yet (right after the initial setup)
    personal_namespace = current_user.namespace
    @personal_repositories = personal_namespace ? personal_namespace.repositories : []

    @stars = current_user.stars.order("updated_at desc")
  end
end
