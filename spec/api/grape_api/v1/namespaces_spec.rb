# frozen_string_literal: true

require "rails_helper"

describe API::V1::Namespaces do
  let!(:admin) { create(:admin) }
  let!(:owner) { create(:user) }
  let!(:contributor) { create(:user) }
  let!(:viewer) { create(:user) }
  let!(:user) { create(:user) }
  let!(:admin_token) { create(:application_token, user: admin) }
  let!(:owner_token) { create(:application_token, user: owner) }
  let!(:contributor_token) { create(:application_token, user: contributor) }
  let!(:viewer_token) { create(:application_token, user: viewer) }
  let!(:user_token) { create(:application_token, user: user) }
  let!(:public_visibility) { Namespace.visibilities[:visibility_public] }
  let!(:hidden_team) do
    create(:team,
           name:   "portus_global_team_1",
           owners: [admin],
           hidden: true)
  end
  let!(:team) do
    create(:team,
           owners:       [owner],
           contributors: [contributor],
           viewers:      [viewer])
  end

  before do
    @admin_header       = build_token_header(admin_token)
    @owner_header       = build_token_header(owner_token)
    @contributor_header = build_token_header(contributor_token)
    @viewer_header      = build_token_header(viewer_token)
    @user_header        = build_token_header(user_token)
  end

  context "GET /api/v1/namespaces" do
    let!(:registry) { create(:registry) }

    context "as admin" do
      it "returns list of accessible namespaces" do
        get "/api/v1/namespaces", nil, @admin_header

        # global + personal + weird ones that I have no idea where it comes from
        # so, magic number :(
        namespaces = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(namespaces.length).to eq(7)
      end
    end

    context "as regular user" do
      it "returns list of accessible namespaces" do
        get "/api/v1/namespaces", nil, @owner_header

        # only personal one
        namespaces = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(namespaces.length).to eq(1)
      end
    end
  end

  context "GET /api/v1/namespaces/:id" do
    it "returns a namespace" do
      namespace = create(:namespace, visibility: public_visibility, team: team)
      get "/api/v1/namespaces/#{namespace.id}", nil, @admin_header

      namespace_parsed = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(namespace_parsed["id"]).to eq(namespace.id)
      expect(namespace_parsed["name"]).to eq(namespace.name)
    end

    it "returns 404 if it doesn't exist" do
      get "/api/v1/namespaces/222", nil, @admin_header

      expect(response).to have_http_status(:not_found)
    end
  end

  context "GET /api/v1/namespaces/:id/repositories" do
    it "returns list of repositories from a namespace" do
      namespace = create(:namespace, visibility: public_visibility, team: team)
      repository = create(:repository, namespace: namespace)
      get "/api/v1/namespaces/#{namespace.id}/repositories", nil, @admin_header

      repositories = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(repositories.length).to eq(1)
      expect(repositories[0]["id"]).to eq(repository.id)
      expect(repositories[0]["name"]).to eq(repository.name)
    end
  end

  context "POST /api/v1/namespaces" do
    let!(:registry) { create(:registry) }

    let(:valid_attributes) do
      { name: "qa_namespace", team: team.name }
    end

    let(:invalid_attributes) do
      { admin: "not valid" }
    end

    context "as admin" do
      it "creates a namespace" do
        post "/api/v1/namespaces", valid_attributes, @admin_header

        namespace = Namespace.last
        namespace_parsed = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(namespace_parsed["id"]).to eq(namespace.id)
        expect(namespace_parsed["name"]).to eq(namespace.name)
      end

      it "creates a team even if feature is disabled" do
        APP_CONFIG["user_permission"]["create_namespace"]["enabled"] = false

        expect do
          post "/api/v1/namespaces", valid_attributes, @admin_header
        end.to change(Namespace, :count).by(1)

        namespace = Namespace.last
        namespace_parsed = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(namespace_parsed["id"]).to eq(namespace.id)
        expect(namespace_parsed["name"]).to eq(namespace.name)
      end
    end

    context "as owner" do
      it "creates a namespace" do
        post "/api/v1/namespaces", valid_attributes, @owner_header

        namespace = Namespace.last
        namespace_parsed = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(namespace_parsed["id"]).to eq(namespace.id)
        expect(namespace_parsed["name"]).to eq(namespace.name)
      end

      it "returns 403 if feature is disabled" do
        APP_CONFIG["user_permission"]["create_namespace"]["enabled"] = false

        post "/api/v1/namespaces", valid_attributes, @owner_header

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "as contributor" do
      it "is not possible to create a namespace inside of a hidden team" do
        params = valid_attributes.merge(team: hidden_team.name)
        post "/api/v1/namespaces", params, @contributor_header

        expect(response).to have_http_status(:not_found)
      end

      it "creates a new namespace" do
        post "/api/v1/namespaces", valid_attributes, @contributor_header

        namespace = Namespace.last
        namespace_parsed = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(namespace_parsed["id"]).to eq(namespace.id)
        expect(namespace_parsed["name"]).to eq(namespace.name)
      end

      it "returns 403 if feature is disabled" do
        APP_CONFIG["user_permission"]["create_namespace"]["enabled"] = false

        post "/api/v1/namespaces", valid_attributes, @owner_header

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "as viewer" do
      it "returns 403 when tries to create a namespace" do
        post "/api/v1/namespaces", valid_attributes, @viewer_header

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "as generic user" do
      it "returns 403 when tries to create a namespace" do
        post "/api/v1/namespaces", valid_attributes, @user_header

        expect(response).to have_http_status(:forbidden)
      end
    end

    it "returns 400 if invalid params" do
      post "/api/v1/namespaces", invalid_attributes, @admin_header

      expect(response).to have_http_status(:bad_request)
    end

    it "returns a 400 for malformed JSON" do
      @admin_header = @admin_header.merge(
        "CONTENT_TYPE" => "application/json",
        "ACCEPT"       => "application/json"
      )
      post "/api/v1/namespaces", "{", @admin_header
      expect(response).to have_http_status(:bad_request)

      resp = JSON.parse(response.body)
      expect(resp["message"]).to match(/There was a problem in the JSON you submitted/)
    end

    it "returns 422 if invalid values" do
      post "/api/v1/namespaces", { name: "", team: team.name }, @admin_header

      parsed = JSON.parse(response.body)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed["message"]["name"].first).to include("can't be blank")
    end

    it "returns 404 if team is hidden" do
      post "/api/v1/namespaces", valid_attributes.merge(team: hidden_team.name), @admin_header

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 if team doesn't exist" do
      post "/api/v1/namespaces", valid_attributes.merge(team: "xpto"), @admin_header

      expect(response).to have_http_status(:not_found)
    end

    it "tracks the creations of new namespaces" do
      expect do
        post "/api/v1/namespaces", valid_attributes, @admin_header
      end.to change(PublicActivity::Activity, :count).by(1)

      namespace = Namespace.last
      namespace_creation_activity = PublicActivity::Activity.find_by(key: "namespace.create")
      expect(namespace_creation_activity.owner).to eq(admin)
      expect(namespace_creation_activity.trackable).to eq(namespace)
    end
  end

  context "DELETE /api/v1/namespaces/:id" do
    let!(:registry) { create(:registry) }

    before do
      APP_CONFIG["delete"]["enabled"] = true
    end

    it "deletes a namespace" do
      namespace = create(:namespace, registry: registry, team: team)

      delete "/api/v1/namespaces/#{namespace.id}", nil, @admin_header
      expect(response).to have_http_status(:no_content)
      expect { Namespace.find(namespace.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "returns 403 when delete is disabled" do
      APP_CONFIG["delete"]["enabled"] = false

      namespace = create(:namespace, registry: registry, team: team)

      delete "/api/v1/namespaces/#{namespace.id}", nil, @admin_header
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 404 when not found" do
      namespace = create(:namespace, registry: registry, team: team)

      delete "/api/v1/namespaces/#{namespace.id + 1}", nil, @admin_header
      expect(response).to have_http_status(:not_found)
    end

    it "returns 422 when a tag could not be removed" do
      namespace = create(:namespace, name: "espriu", registry: registry, team: team)
      repo      = create(:repository, namespace: namespace, name: "sinera")
      create(:tag, repository: repo, name: "cementiri", digest: "1", author: admin)

      allow_any_instance_of(Portus::RegistryClient).to receive(:delete) do
        raise ::Portus::RegistryClient::RegistryError, "I AM ERROR."
      end

      delete "/api/v1/namespaces/#{namespace.id}", nil, @admin_header
      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)
      expect(body["message"]["espriu/sinera"]).to(
        eq "Could not remove repository: could not remove cementiri tag(s)"
      )
    end

    it "returns 422 when the namespace could not be removed" do
      allow_any_instance_of(::Namespaces::DestroyService).to(
        receive(:destroy_repositories!).and_return(true)
      )
      allow_any_instance_of(Namespace).to(receive(:delete_by!).and_return(false))

      namespace = create(:namespace, registry: registry, team: team)
      delete "/api/v1/namespaces/#{namespace.id}", nil, @admin_header
      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)
      expect(body["message"]).to eq "Could not remove namespace"
    end
  end

  context "GET /api/v1/namespaces/validate" do
    it "returns the proper response when the namespace exists" do
      ns = create(:namespace, visibility: public_visibility, team: team)

      get "/api/v1/namespaces/validate", { name: ns.name }, @admin_header
      expect(response).to have_http_status(:success)

      data = JSON.parse(response.body)
      expect(data["valid"]).to be_falsey
      expect(data["messages"]["name"]).to eq(["has already been taken"])
    end

    it "returns the proper response when the namespace does not exist" do
      get "/api/v1/namespaces/validate", { name: "somename" }, @admin_header
      expect(response).to have_http_status(:success)

      data = JSON.parse(response.body)
      expect(data["valid"]).to be_truthy
    end
  end

  context "PUT /api/v1/namespaces/:id" do
    let!(:registry) { create(:registry) }

    let(:namespace_data) do
      {
        name:        "team",
        description: "description",
        visibility:  "public"
      }
    end

    it "updates namespace" do
      namespace = create :namespace, name: "somerandomone", description: "lala"

      put "/api/v1/namespaces/#{namespace.id}", { namespace: namespace_data }, @admin_header
      expect(response).to have_http_status(:success)

      n = Namespace.find(namespace.id)
      expect(n.name).to eq(namespace_data[:name])
      expect(n.description).to eq(namespace_data[:description])
      expect(n.visibility).to eq("visibility_public")
    end

    # Private has a 0 value, and it might be tricky to handle on the server.
    it "can change to private visibility" do
      namespace = create :namespace, visibility: Namespace.visibilities[:visibility_public]

      params = { namespace: { visibility: "private" } }
      put "/api/v1/namespaces/#{namespace.id}", params, @admin_header
      expect(response).to have_http_status(:success)

      n = Namespace.find(namespace.id)
      expect(n.visibility).to eq("visibility_private")
    end

    it "returns duplicate namespace name" do
      n = create :namespace, registry: registry
      n2 = create :namespace, registry: registry

      put "/api/v1/namespaces/#{n.id}", { namespace: { name: n2.name } }, @admin_header
      expect(response).to have_http_status(:unprocessable_entity)

      data = JSON.parse(response.body)["message"]
      expect(data["name"]).to eq(["has already been taken"])
    end

    it "returns status not found" do
      create :namespace
      namespace_id = Namespace.maximum(:id) + 1
      put "/api/v1/namespaces/#{namespace_id}", { namespace: namespace_data }, @admin_header
      expect(response).to have_http_status(:not_found)
    end

    it "changes the team successfully" do
      team = create :team
      team2 = create :team
      namespace = create :namespace, team: team

      put "/api/v1/namespaces/#{namespace.id}",
          { namespace: { team: team2.name } },
          @admin_header
      expect(response).to have_http_status(:success)

      n = Namespace.find(namespace.id)
      expect(n.team.id).to eq(team2.id)
    end

    it "fails to change to a non-existant team" do
      team = create :team
      namespace = create :namespace, team: team

      params = { namespace: { team: team.name + "a" } }
      put "/api/v1/namespaces/#{namespace.id}", params, @admin_header
      expect(response).to have_http_status(:not_found)

      msg = JSON.parse(response.body)["message"]
      expect(msg).to eq("unknown team '#{team.name}a'")
    end

    it "does not allow to change the team by viewers" do
      namespace = create :namespace, team: team
      team2 = create(:team)

      put "/api/v1/namespaces/#{namespace.id}", { namespace: { team: team2.name } }, @viewer_header
      expect(response).to have_http_status(:forbidden)
    end

    it "does not allow to change the description by viewers" do
      namespace = create :namespace, team: team
      put "/api/v1/namespaces/#{namespace.id}", { namespace: namespace_data }, @viewer_header
      expect(response).to have_http_status(:forbidden)
    end

    it "returns a 422 for unknown visibilities" do
      namespace = create :namespace, team: team
      bad_visibility = { namespace: { visibility: "whatever" } }
      put "/api/v1/namespaces/#{namespace.id}", bad_visibility, @admin_header
      expect(response).to have_http_status(:unprocessable_entity)
    end

    context "non-admins are allowed to update namespaces" do
      it "does allow to change the description by owners" do
        namespace       = create :namespace, team: team
        old_description = namespace.description

        expect do
          put "/api/v1/namespaces/#{namespace.id}", { namespace: namespace_data }, @owner_header
        end.to change(PublicActivity::Activity, :count).by(3)
        expect(response).to have_http_status(:success)

        # Tracks the activity

        namespace_description_activity = PublicActivity::Activity.find_by(
          key: "namespace.change_namespace_description"
        )
        expect(namespace_description_activity.owner).to eq(owner)
        expect(namespace_description_activity.trackable).to eq(namespace)
        expect(namespace_description_activity.parameters[:old]).to eq(old_description)
        expect(namespace_description_activity.parameters[:new]).to eq(namespace_data[:description])
      end

      it "changes the team if needed" do
        namespace = create :namespace, team: team
        team2 = create(:team)

        expect do
          put "/api/v1/namespaces/#{namespace.id}",
              { namespace: { team: team2.name } },
              @owner_header
        end.to change(PublicActivity::Activity, :count).by(1)
        expect(response).to have_http_status(:success)

        # Tracks the activity

        namespace_change_team_activity = PublicActivity::Activity.find_by(
          key: "namespace.change_team"
        )
        expect(namespace_change_team_activity.owner).to eq(owner)
        expect(namespace_change_team_activity.trackable).to eq(namespace)
        expect(namespace_change_team_activity.parameters[:old]).to eq(team.id)
        expect(namespace_change_team_activity.parameters[:new]).to eq(team2.id)
      end

      it "changes the visibility if needed" do
        ns = create :namespace, team: team
        put "/api/v1/namespaces/#{ns.id}", { namespace: { visibility: "public" } }, @owner_header
        expect(response).to have_http_status(:success)

        data = JSON.parse(response.body)
        expect(data["visibility"].to_s).to eq "public"
      end

      it "does not allow changing things from other users" do
        namespace = create :namespace, team: team
        put "/api/v1/namespaces/#{namespace.id}", { namespace: namespace_data }, @user_header
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "non-admins are not allowed to update namespaces" do
      before do
        APP_CONFIG["user_permission"]["manage_namespace"]["enabled"] = false
        APP_CONFIG["user_permission"]["change_visibility"]["enabled"] = false
      end

      it "does not allow to change the description by owners" do
        namespace = create :namespace, team: team
        expect do
          put "/api/v1/namespaces/#{namespace.id}", { namespace: namespace_data }, @owner_header
        end.to change(PublicActivity::Activity, :count).by(0)
        expect(response).to have_http_status(:forbidden)
      end

      it "does not change the team" do
        namespace = create :namespace, team: team
        team2 = create(:team)

        expect do
          put "/api/v1/namespaces/#{namespace.id}",
              { namespace: { team: team2.name } },
              @owner_header
        end.to change(PublicActivity::Activity, :count).by(0)
        expect(response).to have_http_status(:forbidden)
      end

      it "does not change the visibility" do
        ns = create :namespace, team: team
        put "/api/v1/namespaces/#{ns.id}", { namespace: { visibility: "public" } }, @owner_header
        expect(response).to have_http_status(:forbidden)
      end

      context "when option user_permission.push_images" do
        before do
          APP_CONFIG["user_permission"]["push_images"]["policy"] = "allow-personal"
        end

        it "raises an authorization error when trying to change to a non-existing team" do
          namespace = create :namespace, team: team
          put "/api/v1/namespaces/#{namespace.id}", { namespace: { team: "a" } }, @owner_header
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
