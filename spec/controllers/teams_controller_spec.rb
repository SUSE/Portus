require 'rails_helper'

RSpec.describe TeamsController, type: :controller do
  let(:valid_attributes) do
    { name: 'qa team' }
  end

  let(:invalid_attributes) do
    { admin: 'not valid' }
  end

  let(:owner) { create(:user) }
  let(:team) { create(:team, owners: [ owner ]) }

  describe 'GET #show' do
    it 'allows team members to view the page' do
      sign_in owner
      get :show, id: team.id

      expect(response.status).to eq 200
    end

    it 'blocks users that are not part of the team' do
      sign_in create(:user)
      get :show, id: team.id

      expect(response.status).to eq 401
    end
  end

  describe 'as a portus user' do
    before :each do
      sign_in owner
    end

    describe 'GET #index' do
      it 'returns the informations about the teams the user is associated with' do
        # another team the user has nothing to do with
        create(:team)

        get :index
        expect(assigns(:teams)).to match_array(owner.teams)
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new Team' do
          expect do
            post :create, { team: valid_attributes, format: :js }
          end.to change(Team, :count).by(1)
          expect(assigns(:team).owners.exists?(owner.id))
        end

        it 'assigns a newly created team as @team' do
          post :create, { team: valid_attributes, format: :js }
          expect(assigns(:team)).to be_a(Team)
          expect(assigns(:team)).to be_persisted
        end

        it 'redirects to the created team' do
          post :create, { team: valid_attributes }
          expect(response).to redirect_to(Team.last)
        end
      end

      context 'with invalid params' do
        it 'assigns a newly created but unsaved team as @team' do
          post :create, { team: invalid_attributes, format: :js }
          expect(assigns(:team)).to be_a_new(Team)
          expect(response.status).to eq 422
        end
      end
    end
  end

  describe 'activity tracking' do
    before :each do
      sign_in owner
    end

    it 'creation of new teams' do
      expect do
        post :create, { team: valid_attributes, format: :js }
      end.to change(PublicActivity::Activity, :count).by(2)

      team = Team.last
      team_creation_activity = PublicActivity::Activity.find_by(key: 'team.create')
      expect(team_creation_activity.owner).to eq(owner)
      expect(team_creation_activity.trackable).to eq(team)

      namespace_creation_activity = PublicActivity::Activity.find_by(key: 'namespace.create')
      expect(namespace_creation_activity.owner).to eq(owner)
      expect(namespace_creation_activity.trackable).to eq(team.namespaces.first)
    end
  end

end
