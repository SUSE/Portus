class ErrorsController < ApplicationController
  skip_before_filter :check_requirements
  skip_before_filter :authenticate_user!
  def show
    text = "Please review your configuration<ul>"
    text += "<li>ssl</li>" if params[:fix_ssl] == "true" 
    text += "<li>secrets</li>" if params[:fix_secrets] == "true"
    text += "</ul>"
    render text: text, status: 500
  end
end
