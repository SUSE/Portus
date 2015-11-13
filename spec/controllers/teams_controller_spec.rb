require "rails_helper"

RSpec.describe TeamsController, type: :controller do
  render_views

  let(:valid_attributes) do
    { name: "qa team", description: "short test description" }
  end

  let(:invalid_attributes) do
    { admin: "not valid" }
  end

  let(:owner) { create(:user) }
  let(:team) { create(:team, description: "short test description", owners: [owner]) }

  describe "GET #show" do

    it "paginates team users" do
      sign_in owner
      get :show, id: team.id
      expect(assigns(:team_users)).to respond_to(:total_pages)
    end

    it "paginates namespaces" do
      sign_in owner
      get :show, id: team.id
      expect(assigns(:team_namespaces)).to respond_to(:total_pages)
    end

    it "allows team members to view the page" do
      sign_in owner
      get :show, id: team.id

      expect(response.status).to eq 200
    end

    it "blocks users that are not part of the team" do
      sign_in create(:user)
      get :show, id: team.id

      expect(response.status).to eq 401
    end

    it "does not display disabled users" do
      user = create(:user, enabled: false)
      TeamUser.create(team: team, user: user, role: TeamUser.roles["viewer"])
      sign_in owner

      get :show, id: team.id

      expect(response.status).to eq 200
      expect(TeamUser.count).to be 2
      expect(assigns(:team_users).count).to be 1
    end
  end

  describe "as a portus user" do
    before :each do
      sign_in owner
    end

    describe "GET #index" do
      it "paginates teams" do
        get :index
        expect(assigns(:teams)).to respond_to(:total_pages)
      end

      it "returns the informations about the teams the user is associated with" do
        # another team the user has nothing to do with
        create(:team)

        get :index
        expect(assigns(:teams)).to be_empty
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new Team" do
          expect do
            post :create, team: valid_attributes, format: :js
          end.to change(Team, :count).by(1)
          expect(assigns(:team).owners.exists?(owner.id))
        end

        it "assigns a newly created team as @team" do
          post :create, team: valid_attributes, format: :js
          expect(assigns(:team)).to be_a(Team)
          expect(assigns(:team)).to be_persisted
        end

        it "redirects to the created team" do
          post :create, team: valid_attributes
          expect(response).to redirect_to(Team.last)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved team as @team" do
          post :create, team: invalid_attributes, format: :js
          expect(assigns(:team)).to be_a_new(Team)
          expect(response.status).to eq 422
        end
      end
    end
  end

  describe "PATCH #update" do
    it "does not allow to change the description or the team name by viewers and contributers" do
      disallowed_roles = ["viewer", "contributer"]
      disallowed_roles.each do |role|
        user = create(:user)
        TeamUser.create(team: team, user: user, role: TeamUser.roles[role])
        sign_in user
        patch :update, id: team.id, team: { name:        "new name",
                                            description: "new description" }, format: "js"
        expect(response.status).to eq(401)
      end
    end

    it "does allow to change the description by owners" do
      sign_in owner
      patch :update, id: team.id, team: { name:        "new name",
                                          description: "new description" }, format: "js"
      expect(response.status).to eq(200)
    end
  end

  describe "typeahead" do
    it "does allow to search for valid users by owners" do
      sign_in owner
      get :typeahead, id: team.id, query: "user", format: "json"
      expect(response.status).to eq(200)
      user1 = create(:user)
      create(:user, username: "user2")
      TeamUser.create(team: team, user: user1, role: TeamUser.roles["viewer"])
      get :typeahead, id: team.id, query: "user", format: "json"
      usernames = JSON.parse(response.body)
      expect(usernames.length).to eq(1)
      expect(usernames[0]["name"]).to eq("user2")
    end

    it "does not allow to search by contributers or viewers" do
      disallowed_roles = ["viewer", "contributer"]
      disallowed_roles.each do |role|
        user = create(:user)
        TeamUser.create(team: team, user: user, role: TeamUser.roles[role])
        sign_in user
        get :typeahead, id: team.id, query: "user", format: "js"
        expect(response.status).to eq(401)
      end
    end
  end

  describe "activity tracking" do
    before :each do
      sign_in owner
    end

    it "creation of new teams" do
      expect do
        post :create, team: valid_attributes, format: :js
      end.to change(PublicActivity::Activity, :count).by(1)

      team = Team.last
      team_creation_activity = PublicActivity::Activity.find_by(key: "team.create")
      expect(team_creation_activity.owner).to eq(owner)
      expect(team_creation_activity.trackable).to eq(team)
    end

    it "editing of a team description" do
      old_description = team.description
      expect do
        patch :update, id: team.id, team: { name:        team.name,
                                            description: "new description" }, format: "js"
      end.to change(PublicActivity::Activity, :count).by(1)

      team_description_activity = PublicActivity::Activity.find_by(
        key: "team.change_team_description")
      expect(team_description_activity.owner).to eq(owner)
      expect(team_description_activity.trackable).to eq(team)
      expect(team_description_activity.parameters[:old]).to eq(old_description)
      expect(team_description_activity.parameters[:new]).to eq("new description")
    end

    it "editing of the team name" do
      old_name = team.name
      expect do
        team_attributes = { name: "new name", description: team.description }
        patch :update, id: team.id, team: team_attributes, format: "js"
      end.to change(PublicActivity::Activity, :count).by(1)

      team_name_activity = PublicActivity::Activity.find_by(
        key: "team.change_team_name")
      expect(team_name_activity.owner).to eq(owner)
      expect(team_name_activity.trackable).to eq(team)
      expect(team_name_activity.parameters[:old]).to eq(old_name)
      expect(team_name_activity.parameters[:new]).to eq("new name")
    end
  end
end
