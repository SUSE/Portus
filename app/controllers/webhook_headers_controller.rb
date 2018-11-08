# frozen_string_literal: true

# WebhookHeadersController manages the creation/removal of webhook headers.
class WebhookHeadersController < ApplicationController
  before_action :set_namespace
  before_action :set_webhook

  after_action :verify_authorized

  # POST /namespaces/1/webhooks/1/headers
  # POST /namespaces/1/webhooks/1/headers.json
  def create
    @webhook_header = @webhook.headers.build(webhook_header_params)
    authorize @webhook_header

    respond_to do |format|
      if @webhook_header.save
        @webhook_header_serialized = API::Entities::WebhookHeaders.represent(
          @webhook_header,
          current_user: current_user,
          type:         :internal
        ).to_json

        format.json { render json: @webhook_header_serialized }
      else
        errors = @webhook_header.errors.full_messages
        format.json { render json: errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /namespaces/1/webhooks/1/headers/1
  # DELETE /namespaces/1/webhooks/1/headers/1.json
  def destroy
    @webhook_header = @webhook.headers.find(params[:id])
    authorize @webhook_header

    @webhook_header.destroy

    render body: nil
  end

  private

  def set_namespace
    @namespace = Namespace.find(params[:namespace_id])
  end

  def set_webhook
    @webhook = @namespace.webhooks.find(params[:webhook_id])
  end

  def webhook_header_params
    params.require(:webhook_header).permit(:name, :value)
  end
end
