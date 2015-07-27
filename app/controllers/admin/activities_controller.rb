require 'csv'

class Admin::ActivitiesController < Admin::BaseController
  respond_to :html, :csv

  def index
    @activities = PublicActivity::Activity.order('created_at DESC').page(params[:page])
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = 'attachment; filename="activities.csv"'
        headers['Content-Type'] = 'text/csv'
      end
    end
  end
end
