# frozen_string_literal: true

# WebhooksController manages the creation/removal/update of webhooks.
# Also, it manages their state, i.e. enabled/disabled.
class WebhooksController < ApplicationController
  before_action :set_namespace
  before_action :set_webhook, only: %i[update show destroy toggle_enabled]

  after_action :verify_authorized, except: [:index]
  after_action :verify_policy_scoped, only: :index

  # GET /namespaces/1/webhooks
  # GET /namespaces/1/webhooks.json
  def index
    authorize @namespace
    @webhooks = policy_scope(Webhook).where(namespace: @namespace).page(params[:page])
    @webhooks_serialized = API::Entities::Webhooks.represent(
      @webhooks,
      current_user: current_user,
      type:         :internal
    ).to_json

    respond_with(@namespace, @webhooks)
  end

  # POST /namespaces/1/webhooks.json
  def create
    @webhook = @namespace.webhooks.build(webhook_params)
    authorize @webhook

    respond_to do |format|
      if @webhook.save
        @webhook.create_activity :create, owner: current_user
        @webhook_serialized = API::Entities::Webhooks.represent(
          @webhook,
          current_user: current_user,
          type:         :internal
        ).to_json

        format.json { render json: @webhook_serialized }
      else
        format.json { render json: @webhook.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /namespaces/1/webhooks/1/1
  # PATCH/PUT /namespaces/1/webhooks/1/1.json
  def update
    authorize @webhook

    respond_to do |format|
      if @webhook.update(webhook_params)
        @webhook.create_activity :update, owner: current_user
        @webhook_serialized = API::Entities::Webhooks.represent(
          @webhook,
          current_user: current_user,
          type:         :internal
        ).to_json

        format.json { render json: @webhook_serialized }
      else
        format.json { render json: @webhook.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # GET /namespaces/1/webhooks/1
  # GET /namespaces/1/webhooks/1.json
  def show
    authorize @webhook

    @deliveries = @webhook.deliveries.page(params[:page])
    respond_with(@namespace, @webhook)
  end

  # DELETE /namespaces/1/webhooks/1
  # DELETE /namespaces/1/webhooks/1.json
  def destroy
    authorize @webhook

    @webhook.create_activity :destroy, owner: current_user
    @webhook.destroy

    respond_with @namespace, @webhook
  end

  # PUT /namespace/1/webhooks/1/toggle_enabled.json
  def toggle_enabled
    authorize @webhook
    @webhook.update_attribute(:enabled, !@webhook.enabled?)
    new_state = @webhook.enabled? ? :enabled : :disabled
    @webhook.create_activity new_state, owner: current_user

    respond_to do |format|
      @webhook_serialized = API::Entities::Webhooks.represent(
        @webhook,
        current_user: current_user,
        type:         :internal
      ).to_json

      format.json { render json: @webhook_serialized }
    end
  end

  private

  def set_namespace
    @namespace = Namespace.find(params[:namespace_id])
    @namespace_serialized = API::Entities::Namespaces.represent(
      @namespace,
      current_user: current_user,
      type:         :internal
    ).to_json
  end

  def set_webhook
    @webhook = @namespace.webhooks.find(params[:id])
    @webhook_serialized = API::Entities::Webhooks.represent(
      @webhook,
      current_user: current_user,
      type:         :internal
    ).to_json
  end

  def webhook_params
    params.require(:webhook).permit(
      :name,
      :url,
      :request_method,
      :content_type,
      :username,
      :password
    )
  end
end
