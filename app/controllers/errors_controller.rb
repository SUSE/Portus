class ErrorsController < ApplicationController
  skip_before_filter :check_requirements
  skip_before_filter :authenticate_user!
  def show
    fix_database = env["action_dispatch.exception"].class == ActiveRecord::NoDatabaseError
    fix_ssl = params[:fix_ssl] == "true"
    fix_secrets = params[:fix_secrets] == "false"
    unless fix_database || fix_ssl || fix_secrets
      text = "We're sorry, but something went wrong.<br/>"
      text += "If you are the application owner check the logs for more information."
      render text: text
      return
    end
    text = "Please review your configuration<ul>"
    text += "<li>ssl</li>" if fix_ssl
    text += "<li>secrets</li>" if fix_secrets
    text += "<li>database</li>" if fix_database
    text += "</ul>"
    render text: text
  end
end
