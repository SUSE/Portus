require "rails_helper"

describe API::V1::Teams do
  let!(:admin) { create(:admin) }
  let!(:token) { create(:application_token, user: admin) }
  let!(:user_token) { create(:application_token, user: create(:user)) }
  let!(:hidden_team) do
    create(:team,
           name:   "portus_global_team_1",
           owners: [admin],
           hidden: true)
  end

  before :each do
    @header = build_token_header(token)
    @user_header = build_token_header(user_token)
  end

  context "GET /api/v1/teams" do
    it "returns an empty list" do
      get "/api/v1/teams", nil, @header

      teams = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(teams.length).to eq(0)
    end

    it "returns list of teams" do
      create_list(:team, 5, owners: [admin])
      get "/api/v1/teams", nil, @header

      teams = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(teams.length).to eq(5)
    end
  end

  context "GET /api/v1/teams/:id" do
    it "returns a team" do
      team = create(:team, owners: [admin])
      get "/api/v1/teams/#{team.id}", nil, @header

      team_parsed = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(team_parsed["id"]).to eq(team.id)
      expect(team_parsed["name"]).to eq(team.name)
    end

    it "returns 404 if it doesn't exist" do
      get "/api/v1/teams/222", nil, @header

      expect(response).to have_http_status(:not_found)
    end
  end

  context "GET /api/v1/teams/:id/namespaces" do
    it "returns list of namespaces from a team" do
      team = create(:team, owners: [admin])
      create_list(:namespace, 5, team: team)
      get "/api/v1/teams/#{team.id}/namespaces", nil, @header

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
      get "/api/v1/teams/#{team.id}/members", nil, @header

      members = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(members.length).to eq(2)
    end
  end

  context "POST /api/v1/teams" do
    let(:valid_attributes) do
      { name: "qa team", description: "short test description" }
    end

    let(:invalid_attributes) do
      { admin: "not valid" }
    end

    it "creates a team" do
      expect do
        post "/api/v1/teams", valid_attributes, @header
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
        post "/api/v1/teams", valid_attributes, @header
      end.to change(Team, :count).by(1)

      team = Team.last
      team_parsed = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(team_parsed["id"]).to eq(team.id)
      expect(team_parsed["name"]).to eq(team.name)
    end

    it "returns 400 if invalid params" do
      post "/api/v1/teams", invalid_attributes, @header

      expect(response).to have_http_status(:bad_request)
    end

    it "returns 422 if invalid values" do
      post "/api/v1/teams", { name: "" }, @header

      parsed = JSON.parse(response.body)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed["errors"]).to include("Name can't be blank")
    end

    it "returns 403 if non-admins try to create a Team" do
      APP_CONFIG["user_permission"]["create_team"]["enabled"] = false

      expect do
        post "/api/v1/teams", valid_attributes, @user_header
      end.to change(Team, :count).by(0)

      expect(response).to have_http_status(:forbidden)
    end

    it "tracks the creations of new teams" do
      expect do
        post "/api/v1/teams", valid_attributes, @header
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

      put "/api/v1/teams/#{team.id}", { team: team_data }, @header
      expect(response).to have_http_status(:success)

      t = Team.find(team.id)
      expect(t.name).to eq(team_data[:name])
      expect(t.description).to eq(team_data[:description])
    end

    it "returns duplicate team name" do
      t = create :team
      t2 = create :team

      put "/api/v1/teams/#{t.id}", { team: { name: t2.name } }, @header
      expect(response).to have_http_status(:bad_request)

      data = JSON.parse(response.body)["errors"]
      expect(data["name"]).to eq(["has already been taken"])
    end

    it "returns status not found" do
      create :team
      team_id = Team.maximum(:id) + 1
      put "/api/v1/teams/#{team_id}", { team: team_data }, @header
      expect(response).to have_http_status(:not_found)
    end
  end
end
