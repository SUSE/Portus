require "rails_helper"

describe API::V1::Teams do
  let!(:admin) { create(:admin) }
  let!(:token) { create(:application_token, user: admin) }
  let!(:hidden_team) do
    create(:team,
           name:   "portus_global_team_1",
           owners: [admin],
           hidden: true)
  end

  before :each do
    @header = build_token_header(token)
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
end
