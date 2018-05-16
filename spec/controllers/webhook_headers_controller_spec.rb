# frozen_string_literal: true

# == Schema Information
#
# Table name: webhook_headers
#
#  id         :integer          not null, primary key
#  webhook_id :integer
#  name       :string(255)
#  value      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_webhook_headers_on_webhook_id           (webhook_id)
#  index_webhook_headers_on_webhook_id_and_name  (webhook_id,name) UNIQUE
#

require "rails_helper"

RSpec.describe WebhookHeadersController, type: :controller do
  let(:valid_session) { {} }
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
          webhook_header: { name: "foo", value: "bar" },
          format:         :json
        }
      end

      it "creates a webhook header" do
        sign_in owner
        post :create, post_params
        expect(response.status).to eq(200)
      end

      it "disallows creating multiple headers with the same name" do
        sign_in owner
        post :create, post_params
        post :create, post_params
        expect(response.status).to eq(422)
      end
    end
  end

  describe "DELETE #destroy" do
    let(:webhook_header) do
      create(:webhook_header, webhook: webhook, name: "foo", value: "bar")
    end

    let(:post_params) do
      {
        id:           webhook_header.id,
        webhook_id:   webhook.id,
        namespace_id: namespace.id,
        format:       :json
      }
    end

    it "allows owner to delete webhook" do
      sign_in owner
      delete :destroy, post_params
      expect(response.status).to eq(200)
    end

    it "disallows user to delete webhook" do
      sign_in user
      delete :destroy, post_params
      expect(response.status).to eq(401)
    end
  end
end
