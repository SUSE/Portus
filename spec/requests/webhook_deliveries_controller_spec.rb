# frozen_string_literal: true

require "rails_helper"

RSpec.describe WebhookDeliveriesController do
  let!(:registry)         { create(:registry) }
  let!(:owner)            { create(:user) }
  let!(:team)             { create(:team, owners: [owner]) }
  let!(:namespace)        { create(:namespace, team: team, registry: registry) }
  let!(:webhook)          { create(:webhook, namespace: namespace) }
  let!(:webhook_delivery) { create(:webhook_delivery, webhook: webhook) }

  before do
    sign_in owner
  end

  describe "#update" do
    before do
      allow_any_instance_of(WebhookDelivery).to receive(:retrigger).and_return(true)
    end

    it "retriggers a webhook delivery" do
      put namespace_webhook_delivery_url(
        webhook_id:   webhook.id,
        id:           webhook_delivery.id,
        namespace_id: namespace.id
      ), params: { format: :json }

      expect(response).to have_http_status(:success)
    end
  end
end
