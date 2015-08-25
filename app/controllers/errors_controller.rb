class ErrorsController < ApplicationController
  skip_before_action :check_requirements
  skip_before_action :authenticate_user!

  def show
    @fix = fixes
    @fix[:database] = env["action_dispatch.exception"].class.name.starts_with? "ActiveRecord"
    render layout: false
  end
end
