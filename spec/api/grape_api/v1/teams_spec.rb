# frozen_string_literal: true

require "rails_helper"

describe API::V1::Teams, type: :request do
  let!(:admin) { create(:admin) }
  let!(:user) { create(:user) }
  let!(:token) { create(:application_token, user: admin) }
  let!(:user_token) { create(:application_token, user: user) }
  let!(:hidden_team) do
    create(:team,
           name:   "portus_global_team_1",
           owners: [admin],
           hidden: true)
  end

  before :each do
    @admin_header = build_token_header(token)
    @user_header = build_token_header(user_token)
  end

  context "GET /api/v1/teams" do
    context "without data" do
      it "returns an empty list" do
        get "/api/v1/teams", params: nil, headers: @admin_header

        teams = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(teams.length).to eq(0)
      end
    end

    context "with data" do
      before do
        create_list(:team, 15, owners: [admin])
      end

      it "returns list of all teams (not paginated)" do
        get "/api/v1/teams", params: { per_page: 10, all: true }, headers: @admin_header

        teams = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(teams.length).to eq(15)
      end

      it "returns list of teams paginated" do
        get "/api/v1/teams", params: { per_page: 10 }, headers: @admin_header

        teams = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(teams.length).to eq(10)
      end

      it "returns list of teams paginated (page 2)" do
        get "/api/v1/teams", params: { per_page: 10, page: 2 }, headers: @admin_header

        teams = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(teams.length).to eq(5)
      end

      it "returns list of all teams ordered" do
        get "/api/v1/teams",
            params:  { sort_attr: "id", sort_order: "desc", per_page: 10 },
            headers: @admin_header

        teams = JSON.parse(response.body)
        teams.each_slice(2) do |a, b|
          expect(a["id"]).to be > b["id"]
        end
      end
    end
  end

  context "GET /api/v1/teams/:id" do
    it "returns a team" do
      team = create(:team, owners: [admin])
      get "/api/v1/teams/#{team.id}", params: nil, headers: @admin_header

      team_parsed = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(team_parsed["id"]).to eq(team.id)
      expect(team_parsed["name"]).to eq(team.name)
    end

    it "returns 404 if it doesn't exist" do
      get "/api/v1/teams/222", params: nil, headers: @admin_header

      expect(response).to have_http_status(:not_found)
    end
  end

  context "GET /api/v1/teams/:id/namespaces" do
    it "returns list of namespaces from a team" do
      team = create(:team, owners: [admin])
      create_list(:namespace, 5, team: team)
      get "/api/v1/teams/#{team.id}/namespaces", params: nil, headers: @admin_header

      namespaces = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(namespaces.length).to eq(5)
    end
  end

  context "GET /api/v1/teams/:id/members" do
    it "returns list of members from a team" do
      user = create(:user)
      team = create(:team, owners: [admin])
      TeamUser.create(team: team, user: user, role: TeamUser.roles[:viewer])
      get "/api/v1/teams/#{team.id}/members", params: nil, headers: @admin_header

      members = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(members.length).to eq(2)
    end
  end

  context "DELETE /api/v1/teams/:id" do
    let!(:registry) { create(:registry) }

    before do
      APP_CONFIG["delete"]["enabled"] = true
    end

    it "deletes a team" do
      team = create(:team, owners: [admin])

      delete "/api/v1/teams/#{team.id}", params: nil, headers: @admin_header
      expect(response).to have_http_status(:no_content)
      expect { Team.find(team.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "deletes a team and migrate all namespaces" do
      team = create(:team, owners: [admin])
      new_team = create(:team, owners: [admin])
      create(:namespace, name: "espriu", registry: registry, team: team)
      params = { new_team: new_team.name }

      delete "/api/v1/teams/#{team.id}", params: params, headers: @admin_header
      expect(response).to have_http_status(:no_content)
      expect(team.namespaces.count).to be 0
      expect(new_team.namespaces.count).to be 1
    end

    it "returns 403 when delete is disabled" do
      APP_CONFIG["delete"]["enabled"] = false

      team = create(:team, owners: [admin])

      delete "/api/v1/teams/#{team.id}", params: nil, headers: @admin_header
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 404 when not found" do
      team = create(:team, owners: [admin])

      delete "/api/v1/teams/#{team.id + 1}", params: nil, headers: @admin_header
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when new team not found" do
      team = create(:team, owners: [admin])
      params = { new_team: "not_found" }

      delete "/api/v1/teams/#{team.id}", params: params, headers: @admin_header
      expect(response).to have_http_status(:not_found)
    end

    it "returns 422 when namespaces could not be migrated" do
      team = create(:team, owners: [admin])
      new_team = create(:team, owners: [admin])
      create(:namespace, name: "espriu", registry: registry, team: team)
      params = { new_team: new_team.name }

      allow_any_instance_of(team.namespaces.class).to(receive(:update_all).and_return(false))

      delete "/api/v1/teams/#{team.id}", params: params, headers: @admin_header
      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)
      expect(body["message"]).to eq "Could not migrate namespaces"
    end

    it "returns 422 when the team could not be removed" do
      allow_any_instance_of(::Teams::DestroyService).to(
        receive(:destroy_namespaces!).and_return(true)
      )
      allow_any_instance_of(Team).to(receive(:delete_by!).and_return(false))

      team = create(:team, owners: [admin])
      delete "/api/v1/teams/#{team.id}", params: nil, headers: @admin_header
      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)
      expect(body["message"]).to eq "Could not remove team"
    end

    it "returns 422 when a tag could not be removed" do
      team      = create(:team, owners: [admin])
      namespace = create(:namespace, name: "espriu", registry: registry, team: team)
      repo      = create(:repository, namespace: namespace, name: "sinera")
      create(:tag, repository: repo, name: "cementiri", digest: "1", author: admin)

      allow_any_instance_of(Portus::RegistryClient).to receive(:delete) do
        raise ::Portus::RegistryClient::RegistryError, "I AM ERROR."
      end

      delete "/api/v1/teams/#{team.id}", params: nil, headers: @admin_header
      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)
      expect(body["message"]["espriu"]["espriu/sinera"]).to(
        eq "Could not remove repository: could not remove cementiri tag(s)"
      )
    end
  end

  context "DELETE /api/v1/teams/:id/members/:member_id" do
    let(:user) { create(:user) }
    let(:team) { create(:team, owners: [admin]) }

    it "removes member from a team" do
      team_user = TeamUser.create(team: team, user: user, role: TeamUser.roles[:viewer])

      expect(team.team_users.count).to eq(2)

      delete "/api/v1/teams/#{team.id}/members/#{team_user.id}", params: nil, headers: @admin_header

      expect(response).to have_http_status(:no_content)
      expect(team.team_users.count).to eq(1)
    end

    it "returns 404 if member doesn't exist" do
      team = create(:team, owners: [admin])

      delete "/api/v1/teams/#{team.id}/members/123", params: nil, headers: @admin_header

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 if team doesn't exist" do
      team_user = TeamUser.create(team: team, user: user, role: TeamUser.roles[:viewer])

      delete "/api/v1/teams/123/members/#{team_user.id}", params: nil, headers: @admin_header

      expect(response).to have_http_status(:not_found)
    end

    it "returns 422 if removing the only owner of the team" do
      team_user_admin = team.team_users.first
      TeamUser.create(team: team, user: user, role: TeamUser.roles[:contributor])

      delete "/api/v1/teams/#{team.id}/members/#{team_user_admin.id}",
             params: nil, headers: @admin_header

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context "PUT /api/v1/teams/:id/members/:member_id" do
    let(:user) { create(:user) }
    let(:team) { create(:team, owners: [admin]) }
    let(:data) { { role: "contributor" } }

    it "updates a member's role of a team" do
      team_user = TeamUser.create(team: team, user: user, role: TeamUser.roles[:viewer])

      expect(team_user.role).to eq("viewer")

      put "/api/v1/teams/#{team.id}/members/#{team_user.id}", params: data, headers: @admin_header

      member = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(member["role"]).to eq("contributor")
    end

    it "returns 400 if data doesn't meet the requirements" do
      put "/api/v1/teams/#{team.id}/members/123", params: nil, headers: @admin_header

      expect(response).to have_http_status(:bad_request)
    end

    it "returns 404 if member doesn't exist" do
      put "/api/v1/teams/#{team.id}/members/123", params: data, headers: @admin_header

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 if team doesn't exist" do
      team_user = TeamUser.create(team: team, user: user, role: TeamUser.roles[:viewer])

      put "/api/v1/teams/123/members/#{team_user.id}", params: data, headers: @admin_header

      expect(response).to have_http_status(404)
    end

    it "returns 422 if trying to demote a portus admin" do
      team_user_admin = team.team_users.first
      TeamUser.create(team: team, user: user, role: TeamUser.roles[:owner])

      put "/api/v1/teams/#{team.id}/members/#{team_user_admin.id}",
          params: data, headers: @admin_header

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 if demoting the only owner of the team" do
      owner = create(:user)
      team = create(:team, owners: [owner])
      team_user_owner = team.team_users.first

      delete "/api/v1/teams/#{team.id}/members/#{team_user_owner.id}",
             params: nil, headers: @admin_header

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context "POST /api/v1/teams/:id/ldap_check" do
    let(:team) { create(:team, owners: [admin], viewers: [user]) }

    it "disables the LDAP check when everything is fine" do
      APP_CONFIG["ldap"]["enabled"] = true
      APP_CONFIG["ldap"]["group_sync"]["enabled"] = true

      expect do
        post "/api/v1/teams/#{team.id}/ldap_check", headers: @admin_header
      end.to change { Team.find_by(name: team.name).ldap_group_checked }
        .from(Team.ldap_statuses[:unchecked])
        .to(Team.ldap_statuses[:disabled])
    end

    it "does not allow anonymous users to perform such operation" do
      APP_CONFIG["ldap"]["enabled"] = true
      APP_CONFIG["ldap"]["group_sync"]["enabled"] = true

      post "/api/v1/teams/#{team.id}/ldap_check"
      expect(response).to have_http_status(401)
    end

    it "does not allow viewer users to perform such operation" do
      APP_CONFIG["ldap"]["enabled"] = true
      APP_CONFIG["ldap"]["group_sync"]["enabled"] = true

      post "/api/v1/teams/#{team.id}/ldap_check", headers: @user_header
      expect(response).to have_http_status(403)
    end

    it "returns a 404 if the team simply doesn't exist" do
      APP_CONFIG["ldap"]["enabled"] = true
      APP_CONFIG["ldap"]["group_sync"]["enabled"] = true

      post "/api/v1/teams/#{team.id * 2}/ldap_check", headers: @admin_header
      expect(response).to have_http_status(404)
    end

    it "returns a 405 if LDAP is disabled" do
      APP_CONFIG["ldap"]["enabled"] = false
      APP_CONFIG["ldap"]["group_sync"]["enabled"] = false

      post "/api/v1/teams/#{team.id}/ldap_check", headers: @admin_header
      expect(response).to have_http_status(405)
    end

    it "returns a 405 if LDAP is enabled but not group_synx" do
      APP_CONFIG["ldap"]["enabled"] = true
      APP_CONFIG["ldap"]["group_sync"]["enabled"] = false

      post "/api/v1/teams/#{team.id}/ldap_check", headers: @admin_header
      expect(response).to have_http_status(405)
    end
  end

  context "POST /api/v1/teams/:id/members" do
    let(:user) { create(:user) }
    let(:team) { create(:team, owners: [admin]) }

    it "adds a member to a team and returns it" do
      data = {
        role: "viewer",
        user: user.username
      }

      expect(team.team_users.count).to eq(1)

      post "/api/v1/teams/#{team.id}/members", params: data, headers: @admin_header

      member = JSON.parse(response.body)
      expect(response).to have_http_status(:created)
      expect(team.team_users.count).to eq(2)
      expect(member["display_name"]).to eq(user.display_username)
      expect(member["role"]).to eq("viewer")
    end

    it "adds portus admin always as owner" do
      another_admin = create(:admin)
      data = {
        role: "viewer",
        user: another_admin.username
      }

      post "/api/v1/teams/#{team.id}/members", params: data, headers: @admin_header

      member = JSON.parse(response.body)
      expect(response).to have_http_status(:created)
      expect(member["role"]).to eq("owner")
    end

    it "returns 404 if team doesn't exist" do
      data = {
        role: "viewer",
        user: user.username
      }

      post "/api/v1/teams/123/members", params: data, headers: @admin_header

      expect(response).to have_http_status(404)
    end

    it "returns 404 if user doesn't exist" do
      data = {
        role: "viewer",
        user: "user"
      }

      post "/api/v1/teams/#{team.id}/members", params: data, headers: @admin_header

      expect(response).to have_http_status(404)
    end

    it "returns 422 if user already belongs to the team" do
      data = {
        role: "viewer",
        user: admin.username
      }

      post "/api/v1/teams/#{team.id}/members", params: data, headers: @admin_header

      expect(response).to have_http_status(422)
    end

    it "returns 400 if data doesn't meet the requirements" do
      post "/api/v1/teams/#{team.id}/members", params: nil, headers: @admin_header

      expect(response).to have_http_status(:bad_request)
    end
  end

  context "POST /api/v1/teams" do
    let(:valid_attributes) do
      { name: "qa team", description: "short test description" }
    end

    let(:owner_valid_attributes) do
      { name: "qa team", description: "short test description", owner_id: user.id }
    end

    let(:invalid_attributes) do
      { admin: "not valid" }
    end

    it "creates a team" do
      expect do
        post "/api/v1/teams", params: valid_attributes, headers: @admin_header
      end.to change(Team, :count).by(1)

      team = Team.last
      team_parsed = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(team_parsed["id"]).to eq(team.id)
      expect(team_parsed["name"]).to eq(team.name)
    end

    it "creates a team even if feature is disabled and admin" do
      APP_CONFIG["user_permission"]["create_team"]["enabled"] = false

      expect do
        post "/api/v1/teams", params: valid_attributes, headers: @admin_header
      end.to change(Team, :count).by(1)

      team = Team.last
      team_parsed = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(team_parsed["id"]).to eq(team.id)
      expect(team_parsed["name"]).to eq(team.name)
    end

    it "creates a team with different owner" do
      expect do
        post "/api/v1/teams", params: owner_valid_attributes, headers: @admin_header
      end.to change(Team, :count).by(1)

      team = Team.last
      team_parsed = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(team_parsed["id"]).to eq(team.id)
      expect(team_parsed["name"]).to eq(team.name)
    end

    it "returns 403 if current user is not admin when creating a team with different owner" do
      post "/api/v1/teams", params: owner_valid_attributes, headers: @user_header

      expect(response).to have_http_status(:forbidden)
    end

    it "returns 400 if invalid params" do
      post "/api/v1/teams", params: invalid_attributes, headers: @admin_header

      expect(response).to have_http_status(:bad_request)
    end

    it "returns a 400 for malformed JSON" do
      @admin_header = @admin_header.merge(
        "CONTENT_TYPE" => "application/json",
        "ACCEPT"       => "application/json"
      )
      post "/api/v1/teams", params: "{", headers: @admin_header
      expect(response).to have_http_status(:bad_request)

      resp = JSON.parse(response.body)
      expect(resp["message"]).to match(%r{When specifying application/json as content-type})
    end

    it "returns 422 if invalid values" do
      post "/api/v1/teams", params: { name: "" }, headers: @admin_header

      parsed = JSON.parse(response.body)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed["message"]["name"].first).to include("can't be blank")
    end

    it "returns 403 if non-admins try to create a Team" do
      APP_CONFIG["user_permission"]["create_team"]["enabled"] = false

      expect do
        post "/api/v1/teams", params: valid_attributes, headers: @user_header
      end.to change(Team, :count).by(0)

      expect(response).to have_http_status(:forbidden)
    end

    it "tracks the creations of new teams" do
      expect do
        post "/api/v1/teams", params: valid_attributes, headers: @admin_header
      end.to change(PublicActivity::Activity, :count).by(1)

      team = Team.last
      team_creation_activity = PublicActivity::Activity.find_by(key: "team.create")
      expect(team_creation_activity.owner).to eq(admin)
      expect(team_creation_activity.trackable).to eq(team)
    end
  end

  context "PUT /api/v1/teams/:id" do
    let(:team_data) do
      {
        name:        "team",
        description: "description"
      }
    end

    it "updates team" do
      team = create :team, name: "somerandomone", description: "lala"

      expect do
        put "/api/v1/teams/#{team.id}", params: { team: team_data }, headers: @admin_header
      end.to change(PublicActivity::Activity, :count).by(2)
      expect(response).to have_http_status(:success)

      t = Team.find(team.id)
      expect(t.name).to eq(team_data[:name])
      expect(t.description).to eq(team_data[:description])

      # Tracks activity

      team_description_activity = PublicActivity::Activity.find_by(
        key: "team.change_team_description"
      )
      expect(team_description_activity.owner).to eq(admin)
      expect(team_description_activity.trackable).to eq(team)
      expect(team_description_activity.parameters[:old]).to eq("lala")
      expect(team_description_activity.parameters[:new]).to eq(team_data[:description])

      team_name_activity = PublicActivity::Activity.find_by(
        key: "team.change_team_name"
      )
      expect(team_name_activity.owner).to eq(admin)
      expect(team_name_activity.trackable).to eq(team)
      expect(team_name_activity.parameters[:old]).to eq("somerandomone")
      expect(team_name_activity.parameters[:new]).to eq("team")
    end

    it "does not allow viewers or contributors to update" do
      team = create :team,
                    name:        "somerandomone",
                    description: "lala",
                    owners:      [admin],
                    viewers:     [user]

      put "/api/v1/teams/#{team.id}", params: { team: team_data }, headers: @user_header
      expect(response).to have_http_status(:forbidden)
    end

    it "returns duplicate team name" do
      t = create :team
      t2 = create :team

      put "/api/v1/teams/#{t.id}", params: { team: { name: t2.name } }, headers: @admin_header
      expect(response).to have_http_status(:unprocessable_entity)

      data = JSON.parse(response.body)["message"]
      expect(data["name"]).to eq(["has already been taken"])
    end

    it "returns status not found" do
      create :team
      team_id = Team.maximum(:id) + 1
      put "/api/v1/teams/#{team_id}", params: { team: team_data }, headers: @admin_header
      expect(response).to have_http_status(:not_found)
    end

    it "does not allow a hidden team to be changed" do
      put "/api/v1/teams/#{hidden_team.id}", params: { team: team_data }, headers: @admin_header
      expect(response).to have_http_status(:forbidden)
    end

    context "non-admins are allowed to update teams" do
      it "does allow to change the description by owners" do
        team = create :team,
                      name:        "somerandomone",
                      description: "lala",
                      owners:      [user]

        put "/api/v1/teams/#{team.id}", params: { team: team_data }, headers: @user_header
        expect(response).to have_http_status(:success)
      end
    end

    context "non-admins are not allowed to update teams" do
      before do
        APP_CONFIG["user_permission"]["manage_team"]["enabled"] = false
      end

      it "prohibits owners from changing the description" do
        team = create :team,
                      name:        "somerandomone",
                      description: "lala",
                      owners:      [user]

        put "/api/v1/teams/#{team.id}", params: { team: team_data }, headers: @user_header
        expect(response).to have_http_status(:forbidden)
      end

      it "allows admins to change the description" do
        team = create :team,
                      name:        "somerandomone",
                      description: "lala",
                      owners:      [user]

        put "/api/v1/teams/#{team.id}", params: { team: team_data }, headers: @admin_header
        expect(response).to have_http_status(:success)
      end
    end
  end
end
