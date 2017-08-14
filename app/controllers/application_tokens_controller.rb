# ApplicationTokensController manages the creation/removal of application tokens
class ApplicationTokensController < ApplicationController
  respond_to :js

  # POST /application_tokens
  def create
    @application_token, @plain_token = ApplicationToken.create_token(
      current_user: current_user, params: create_params
    )

    if @application_token.errors.empty?
      respond_with @application_token
    else
      respond_with @application_token.errors, status: :unprocessable_entity
    end
  end

  # DELETE /application_token/1
  def destroy
    @application_token = ApplicationToken.find(params[:id])
    @application_token.create_activity!(:destroy, current_user)
    @application_token.destroy

    respond_with @application_token
  end

  private

  def create_params
    permitted = [:application]
    params.require(:application_token).permit(permitted)
  end
end
