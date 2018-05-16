# frozen_string_literal: true

# WebhookDeliveriesController manages the updates of webhook deliveries.
class WebhookDeliveriesController < ApplicationController
  respond_to :html, :js

  after_action :verify_authorized

  # PATCH/PUT /namespaces/1/webhooks/1/deliveries/1
  def update
    namespace = Namespace.find(params[:namespace_id])
    webhook = namespace.webhooks.find(params[:webhook_id])
    webhook_delivery = webhook.deliveries.find(params[:id])

    authorize webhook_delivery

    webhook_delivery.retrigger

    respond_to do |format|
      @webhook_delivery_serialized = API::Entities::WebhookDeliveries.represent(
        webhook_delivery,
        current_user: current_user,
        type:         :internal
      ).to_json

      format.json { render json: @webhook_delivery_serialized }
    end
  end
end
