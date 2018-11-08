# frozen_string_literal: true

require "rails_helper"

RSpec.describe WebhookHeadersController do
  let!(:registry) { create(:registry) }
  let(:user) { create(:user) }
  let(:viewer) { create(:user) }
  let(:contributor) { create(:user) }
  let(:owner) { create(:user) }
  let(:team) do
    create(:team,
           owners:       [owner],
           viewers:      [user, viewer],
           contributors: [contributor])
  end
  let(:namespace) do
    create(
      :namespace,
      team:        team,
      description: "short test description",
      registry:    registry
    )
  end
  let(:webhook) { create(:webhook, namespace: namespace) }

  describe "POST #create" do
    context "as a namespace owner" do
      let(:post_params) do
        {
          webhook_id:     webhook.id,
          namespace_id:   namespace.id,
          webhook_header: { name: "foo", value: "bar" }
        }
      end

      it "creates a webhook header" do
        sign_in owner
        post namespace_webhook_headers_url(post_params), params: { format: :json }
        expect(response.status).to eq(200)
      end

      it "disallows creating multiple headers with the same name" do
        sign_in owner
        post namespace_webhook_headers_url(post_params), params: { format: :json }
        post namespace_webhook_headers_url(post_params), params: { format: :json }
        expect(response.status).to eq(422)
      end
    end
  end

  describe "DELETE #destroy" do
    let(:webhook_header) do
      create(:webhook_header, webhook: webhook, name: "foo", value: "bar")
    end

    it "allows owner to delete webhook" do
      sign_in owner
      delete namespace_webhook_header_url(
        namespace_id: namespace.id,
        webhook_id:   webhook.id,
        id:           webhook_header.id
      ), params: { format: :json }
      expect(response.status).to eq(200)
    end

    it "disallows user to delete webhook" do
      sign_in user
      delete namespace_webhook_header_url(
        namespace_id: namespace.id,
        webhook_id:   webhook.id,
        id:           webhook_header.id
      ), params: { format: :json }
      expect(response.status).to eq(401)
    end
  end
end
