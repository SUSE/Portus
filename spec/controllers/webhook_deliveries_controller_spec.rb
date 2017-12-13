# frozen_string_literal: true

# == Schema Information
#
# Table name: webhook_deliveries
#
#  id              :integer          not null, primary key
#  webhook_id      :integer
#  uuid            :string(255)
#  status          :integer
#  request_header  :text(65535)
#  request_body    :text(65535)
#  response_header :text(65535)
#  response_body   :text(65535)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_webhook_deliveries_on_webhook_id           (webhook_id)
#  index_webhook_deliveries_on_webhook_id_and_uuid  (webhook_id,uuid) UNIQUE
#

require "rails_helper"

RSpec.describe WebhookDeliveriesController, type: :controller do
  render_views

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
      put :update, namespace_id: namespace.id, webhook_id: webhook.id, id: webhook_delivery.id
      expect(response).to have_http_status(:success)
    end
  end
end
