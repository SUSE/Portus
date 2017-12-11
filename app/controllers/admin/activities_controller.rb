# frozen_string_literal: true

require "csv"

class Admin::ActivitiesController < Admin::BaseController
  respond_to :html, :csv

  def index
    respond_to do |format|
      format.html do
        @activities = PublicActivity::Activity.order(created_at: :desc).page(params[:page])
      end
      format.csv do
        @activities = PublicActivity::Activity.order(created_at: :desc)
        headers["Content-Disposition"] = 'attachment; filename="activities.csv"'
        headers["Content-Type"] = "text/csv"
      end
    end
  end
end
