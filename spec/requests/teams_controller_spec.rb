# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeamsController do
  let(:valid_attributes) do
    { name: "qa team", description: "short test description" }
  end

  let(:invalid_attributes) do
    { admin: "not valid" }
  end

  # TODO: (mssola) re-factor this so the team is always created. I've had to
  # modify some tests that are not obvious because of the lazyness of `let` vs
  # `let!`.
  let!(:owner) { create(:user) }
  let(:team) { create(:team, description: "short test description", owners: [owner]) }
  let!(:hidden_team) do
    create(:team, name: "portus_global_team_1",
           description: "short test description", owners: [owner],
           hidden: true)
  end
  # creating a registry also creates an admin user who is needed later on
  let!(:registry) { create(:registry) }

  describe "GET #show" do
    it "allows team members to view the page" do
      sign_in owner
      get team_url(id: team.id)

      expect(response.status).to eq 200
    end

    it "blocks users that are not part of the team" do
      sign_in create(:user)
      get team_url(id: team.id)

      expect(response.status).to eq 401
    end

    it "drops requests to a hidden team" do
      sign_in owner

      expect do
        get team_url(id: hidden_team.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not display disabled users" do
      user = create(:user, enabled: false)
      TeamUser.create(team: team, user: user, role: TeamUser.roles["viewer"])
      sign_in owner

      get team_url(id: team.id)

      expect(response.status).to eq 200
      expect(TeamUser.count).to be 6
      expect(JSON.parse(assigns(:team_users_serialized)).size).to be 1
    end
  end

  describe "as a portus user" do
    before do
      sign_in owner
    end

    describe "GET #index" do
      it "returns the informations about the teams the user is associated with" do
        # another team the user has nothing to do with
        create(:team)

        get teams_url
        expect(assigns(:teams)).to be_empty
      end
    end
  end

  describe "typeahead" do
    it "does allow to search for valid users by owners" do
      sign_in owner
      get "/teams/#{team.id}/typeahead/user", params: { format: "json" }
      expect(response.status).to eq(200)
      user1 = create(:user)
      create(:user, username: "user2")
      TeamUser.create(team: team, user: user1, role: TeamUser.roles["viewer"])
      get typeahead_team_url(id: team.id, query: "user"), params: { format: "json" }
      usernames = JSON.parse(response.body)
      # usernames also includes the admin user, and some other user
      # which is automatically created when creating the registry
      expect(usernames.length).to eq(2)
      expect(usernames).to include("name" => "user2")
    end

    it "does not allow to search by contributors or viewers" do
      disallowed_roles = %w[viewer contributer]
      disallowed_roles.each do |role|
        user = create(:user)
        TeamUser.create(team: team, user: user, role: TeamUser.roles[role])
        sign_in user
        get typeahead_team_url(id: team.id, query: "user"), params: { format: "js" }
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#all_with_query" do
    it "fetches all the teams available" do
      sign_in owner

      # At this point the `team` variable has not been instantiated on the DB
      # yet, so the result will be empty (the global team is rightfully not
      # picked).
      get "/teams/typeahead/team", params: { format: "json" }
      teams = JSON.parse(response.body)
      expect(teams).to be_empty

      # Thus forcing the creation of the team too.
      TeamUser.create(
        team: team,
        user: create(:user),
        role: TeamUser.roles["viewer"]
      )

      get "/teams/typeahead/team", params: { format: "json" }
      teams = JSON.parse(response.body)
      expect(teams.size).to eq(1)
      expect(teams.first["name"]).to eq(team.name)
    end
  end
end
