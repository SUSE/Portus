# frozen_string_literal: true

require "rails_helper"

RSpec.describe WebhooksController do
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
  let!(:webhook) do
    create(
      :webhook,
      namespace: namespace
    )
  end
  let!(:webhook_header) { create(:webhook_header, webhook: webhook) }
  let!(:webhook_delivery) { create(:webhook_delivery, webhook: webhook) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "assigns all webhooks as @webhooks" do
      get namespace_webhooks_url(namespace_id: namespace.to_param)
      expect(assigns(:webhooks)).to match_array(
        [Webhook.find_by(namespace: namespace)]
      )
    end
  end

  describe "GET #show" do
    it "allows team members to view the page" do
      sign_in owner
      get namespace_webhook_url(id: webhook.id, namespace_id: namespace.to_param)

      expect(assigns(:webhook)).to eq(webhook)
      expect(response.status).to eq 200
    end

    it "blocks users that are not part of the team" do
      sign_in create(:user)
      get namespace_webhook_url(id: webhook.id, namespace_id: namespace.to_param)

      expect(response.status).to eq 401
    end
  end

  describe "DELETE #destroy" do
    context "as a contributor of the team that is going to control webhooks" do
      it "blocks access" do
        sign_in contributor

        expect do
          delete namespace_webhook_url(id: webhook.id, namespace_id: namespace.to_param)
        end.not_to change(Webhook, :count)
        expect(response.status).to eq(401)
      end
    end

    context "as a viewer of the team that is going to control webhooks" do
      it "blocks access" do
        sign_in viewer

        expect do
          delete namespace_webhook_url(id: webhook.id, namespace_id: namespace.to_param)
        end.not_to change(Webhook, :count)
        expect(response.status).to eq(401)
      end

      it "shows an error message" do
        sign_in viewer
        delete namespace_webhook_url(id: webhook.id, namespace_id: namespace.to_param), xhr: true
        expect(response.body).to include("You are not authorized to access this page")
      end
    end

    context "as a generic user not part of the team that is going to control webhooks" do
      it "blocks access" do
        sign_in create(:user)

        expect do
          delete namespace_webhook_url(id: webhook.id, namespace_id: namespace.to_param)
        end.not_to change(Webhook, :count)
        expect(response.status).to eq(401)
      end
    end

    it "deletes a webhook" do
      sign_in owner
      delete namespace_webhook_url(id: webhook.id, namespace_id: namespace.to_param)
      expect(response.status).to eq 302
    end
  end

  describe "PUT #toggle_enabled" do
    it "allows the owner of the team to change the enabled attribute", single: true do
      sign_in owner
      put toggle_enabled_namespace_webhook_url(namespace_id: namespace.id, id: webhook.id),
          params: { format: :json }

      webhook.reload
      expect(webhook).not_to be_enabled
      expect(response.status).to eq 200
    end

    it "blocks users that are not part of the team" do
      sign_in create(:user)
      put toggle_enabled_namespace_webhook_url(namespace_id: namespace.id, id: webhook.id),
          params: { format: :json }

      expect(response.status).to eq 401
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      {
        name:      "webhook",
        namespace: namespace.id,
        url:       "example.org"
      }
    end

    let(:invalid_attributes) do
      {
        namespace: namespace.id
      }
    end

    context "as a contributor of the team that is going to control webhooks" do
      it "blocks access" do
        sign_in contributor

        expect do
          post namespace_webhooks_url(webhook: valid_attributes, namespace_id: namespace.id),
               params: { format: :js }
        end.not_to change(Webhook, :count)
        expect(response.status).to eq(401)
      end
    end

    context "as a viewer of the team that is going to control webhooks" do
      it "blocks access" do
        sign_in viewer

        expect do
          post namespace_webhooks_url(webhook: valid_attributes, namespace_id: namespace.id),
               params: { format: :js }
        end.not_to change(Webhook, :count)
        expect(response.status).to eq(401)
      end
    end

    context "as a generic user not part of the team that is going to control webhooks" do
      it "blocks access" do
        sign_in create(:user)

        expect do
          post namespace_webhooks_url(webhook: valid_attributes, namespace_id: namespace.id),
               params: { format: :js }
        end.not_to change(Webhook, :count)
        expect(response.status).to eq(401)
      end
    end

    context "with valid params" do
      before do
        sign_in owner
      end

      it "creates a new webhook" do
        expect do
          post namespace_webhooks_url(webhook: valid_attributes, namespace_id: namespace.id),
               params: { format: :json }
        end.to change(Webhook, :count).by(1)
        expect(assigns(:webhook).namespace).to eq(namespace)
        expect(assigns(:webhook).url).to eq("http://#{valid_attributes[:url]}")
        expect(assigns(:webhook).enabled).to be_falsy
      end

      it "assigns a newly created webhook as @webhook" do
        post namespace_webhooks_url(webhook: valid_attributes, namespace_id: namespace.id),
             params: { format: :json }
        expect(assigns(:webhook)).to be_a(Webhook)
        expect(assigns(:webhook)).to be_persisted
      end

      it "creates a new webhook with the given username" do
        attrs = valid_attributes.dup
        attrs["username"] = "user"

        expect do
          post namespace_webhooks_url(webhook: attrs, namespace_id: namespace.id),
               params: { format: :json }
        end.to change(Webhook, :count).by(1)
        expect(assigns(:webhook).namespace).to eq(namespace)
        expect(assigns(:webhook).url).to eq("http://#{valid_attributes[:url]}")
        expect(assigns(:webhook).username).to eq("user")
      end

      it "creates a new webhook with the given password" do
        attrs = valid_attributes.dup
        attrs["password"] = "password"

        expect do
          post namespace_webhooks_url(webhook: attrs, namespace_id: namespace.id),
               params: { format: :json }
        end.to change(Webhook, :count).by(1)
        expect(assigns(:webhook).namespace).to eq(namespace)
        expect(assigns(:webhook).url).to eq("http://#{valid_attributes[:url]}")
        expect(assigns(:webhook).password).to eq("password")
      end

      it "creates a new webhook with the POST method" do
        attrs = valid_attributes.dup
        attrs["request_method"] = "POST"

        expect do
          post namespace_webhooks_url(webhook: attrs, namespace_id: namespace.id),
               params: { format: :json }
        end.to change(Webhook, :count).by(1)
        expect(assigns(:webhook).namespace).to eq(namespace)
        expect(assigns(:webhook).url).to eq("http://#{valid_attributes[:url]}")
        expect(assigns(:webhook).request_method).to eq("POST")
      end

      it "creates a new webhook with the JSON content type" do
        attrs = valid_attributes.dup
        attrs["content_type"] = "application/json"

        expect do
          post namespace_webhooks_url(webhook: attrs, namespace_id: namespace.id),
               params: { format: :json }
        end.to change(Webhook, :count).by(1)
        expect(assigns(:webhook).namespace).to eq(namespace)
        expect(assigns(:webhook).url).to eq("http://#{valid_attributes[:url]}")
        expect(assigns(:webhook).content_type).to eq("application/json")
      end
    end

    context "with invalid params" do
      before do
        sign_in owner
      end

      it "assigns a newly created but unsaved webhook as @webhook" do
        post namespace_webhooks_url(webhook: invalid_attributes, namespace_id: namespace.id),
             params: { format: :json }
        expect(assigns(:webhook)).to be_a_new(Webhook)
        expect(response.status).to eq(422)
      end

      it "fails to create a webhook with an invalid request method" do
        post namespace_webhooks_url(
          webhook:        invalid_attributes,
          request_method: "PUT",
          namespace_id:   namespace.id
        ), params: { format: :json }
        expect(assigns(:webhook)).to be_a_new(Webhook)
        expect(response.status).to eq(422)
      end

      it "fails to create a webhook with an invalid content type" do
        post namespace_webhooks_url(
          webhook:      invalid_attributes,
          content_type: "text/plain",
          namespace_id: namespace.id
        ), params: { format: :json }
        expect(assigns(:webhook)).to be_a_new(Webhook)
        expect(response.status).to eq(422)
      end
    end
  end

  describe "PATCH #update" do
    it "does not allow to change the url by viewers" do
      team = create(:team)
      user = create(:user)
      TeamUser.create(team: team, user: user, role: TeamUser.roles["viewers"])
      sign_in user
      patch namespace_webhook_url(
        namespace_id: namespace.id,
        id:           webhook.id,
        webhook:      { url: "port.us" },
        format:       :js
      )
      expect(response.status).to eq(401)
    end

    it "does not allow to change the request method by viewers" do
      team = create(:team)
      user = create(:user)
      TeamUser.create(team: team, user: user, role: TeamUser.roles["viewers"])
      sign_in user
      patch namespace_webhook_url(
        namespace_id: namespace.id,
        id:           webhook.id,
        webhook:      { request_method: "POST" },
        format:       :json
      )
      expect(response.status).to eq(401)
    end

    it "does not allow to change the content type by viewers" do
      team = create(:team)
      user = create(:user)
      TeamUser.create(team: team, user: user, role: TeamUser.roles["viewers"])
      sign_in user
      patch namespace_webhook_url(
        namespace_id: namespace.id,
        id:           webhook.id,
        webhook:      { content_type: "application/json" },
        format:       :json
      )
      expect(response.status).to eq(401)
    end

    it "does not allow to change the username by viewers" do
      team = create(:team)
      user = create(:user)
      TeamUser.create(team: team, user: user, role: TeamUser.roles["viewers"])
      sign_in user
      patch namespace_webhook_url(
        namespace_id: namespace.id,
        id:           webhook.id,
        webhook:      { username: "alice" },
        format:       :json
      )
      expect(response.status).to eq(401)
    end

    it "does not allow to change the password by viewers" do
      team = create(:team)
      user = create(:user)
      TeamUser.create(team: team, user: user, role: TeamUser.roles["viewers"])
      sign_in user
      patch namespace_webhook_url(
        namespace_id: namespace.id,
        id:           webhook.id,
        webhook:      { password: "supersecure" },
        format:       :json
      )
      expect(response.status).to eq(401)
    end

    it "does allow to change the url by owners" do
      sign_in owner
      patch namespace_webhook_url(
        namespace_id: namespace.id,
        id:           webhook.id,
        webhook:      { url: "port.us" },
        format:       :json
      )
      expect(response.status).to eq(200)
    end

    it "fails when providing invalid parameters" do
      sign_in owner
      patch namespace_webhook_url(
        namespace_id: namespace.id,
        id:           webhook.id,
        webhook:      { url: "" },
        format:       :json
      )
      expect(response.status).to eq(422)
    end
  end

  describe "activity tracking" do
    before do
      sign_in owner
    end

    it "tracks webhook creation" do
      expect do
        post namespace_webhooks_url(
          webhook:      { name: "webhook", namespace: namespace.id, url: "example.org" },
          namespace_id: namespace.id
        ), params: { format: :json }
      end.to change(PublicActivity::Activity, :count).by(1)

      activity = PublicActivity::Activity.last
      expect(activity.key).to eq("webhook.create")
      expect(activity.owner).to eq(owner)
      expect(activity.trackable).to eq(Webhook.last)
    end

    it "tracks set webhook enabled" do
      webhook.update(enabled: false)

      expect do
        put toggle_enabled_namespace_webhook_url(
          namespace_id: namespace.id,
          id:           webhook.id,
          format:       :json
        )
      end.to change(PublicActivity::Activity, :count).by(1)

      activity = PublicActivity::Activity.last
      expect(activity.key).to eq("webhook.enabled")
      expect(activity.owner).to eq(owner)
      expect(activity.trackable).to eq(webhook)
    end

    it "tracks set webhook disabled" do
      webhook.update(enabled: true)

      expect do
        put toggle_enabled_namespace_webhook_url(
          namespace_id: namespace.id,
          id:           webhook.id,
          format:       :json
        )
      end.to change(PublicActivity::Activity, :count).by(1)

      activity = PublicActivity::Activity.last
      expect(activity.key).to eq("webhook.disabled")
      expect(activity.owner).to eq(owner)
      expect(activity.trackable).to eq(webhook)
    end

    it "tracks updates to the webhook" do
      expect do
        patch namespace_webhook_url(
          namespace_id: namespace.id,
          id:           webhook.id,
          webhook:      { url: "port.us" },
          format:       :json
        )
      end.to change(PublicActivity::Activity, :count).by(1)
    end

    it "tracks removal of the webhook" do
      expect do
        delete namespace_webhook_url(
          namespace_id: namespace.id,
          id:           webhook.id,
          webhook:      { url: "port.us" },
          format:       :json
        )
      end.to change(PublicActivity::Activity, :count).by(1)
    end
  end
end
