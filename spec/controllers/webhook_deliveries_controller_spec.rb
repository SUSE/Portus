require "rails_helper"

RSpec.describe WebhookDeliveriesController, type: :controller do
  render_views

  let!(:registry)         { create(:registry) }
  let!(:owner)            { create(:user) }
  let!(:team)             { create(:team, owners: [owner]) }
  let!(:namespace)        { create(:namespace, team: team, registry: registry) }
  let!(:webhook)          { create(:webhook, namespace: namespace) }
  let!(:webhook_delivery) { create(:webhook_delivery, webhook: webhook) }

  before :each do
    sign_in owner
  end

  describe "#update" do
    before :each do
      allow_any_instance_of(WebhookDelivery).to receive(:retrigger).and_return(true)
    end

    it "retriggers a webhook delivery" do
      put :update, namespace_id: namespace.id, webhook_id: webhook.id, id: webhook_delivery.id
      expect(response).to have_http_status(:success)
    end
  end
end
