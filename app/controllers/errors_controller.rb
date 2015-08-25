class ErrorsController < ApplicationController
  skip_before_filter :check_requirements
  skip_before_filter :authenticate_user!
  def show
    @fix_database = env["action_dispatch.exception"].class == ActiveRecord::NoDatabaseError
    @fix_ssl = params[:fix_ssl] == "true"
    @fix_secrets = params[:fix_secrets] == "true"
    render :layout => false
  end
end
