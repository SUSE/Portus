require 'rails_helper'

describe NamespacesController do

  let(:valid_session) { {} }
  let(:user) { create(:user) }
  let(:viewer) { create(:user) }
  let(:contributor) { create(:user) }
  let(:owner) { create(:user) }
  let(:team) do
    create(:team,
           owners: [ owner ],
           viewers: [ user, viewer ],
           contributors: [ contributor ])
  end
  let(:namespace) { create(:namespace, team: team) }

  before :each do
    sign_in user
  end

  describe 'GET #index' do

    it 'assigns all namespaces as @namespaces' do
      get :index, {}, valid_session
      expect(assigns(:namespaces).ids).to match_array(Namespace.all.ids)
    end

  end

  describe 'GET #show' do
    it 'allows team members to view the page' do
      sign_in owner
      get :show, id: namespace.id

      expect(assigns(:namespace)).to eq(namespace)
      expect(response.status).to eq 200
    end

    it 'blocks users that are not part of the team' do
      sign_in create(:user)
      get :show, id: namespace.id

      expect(response.status).to eq 401
    end
  end

  describe 'PUT #toggle_public' do
    it 'allows the owner of the team to change the public attribute' do
      sign_in owner
      put :toggle_public, id: namespace.id, format: :js

      namespace.reload
      expect(namespace).to be_public
      expect(response.status).to eq 200
    end

    it 'blocks users that are not part of the team' do
      sign_in create(:user)
      put :toggle_public, id: namespace.id, format: :js

      expect(response.status).to eq 401
    end

  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        team: team.name,
        namespace: 'qa_team_namespace'
      }
    end

    let(:invalid_attributes) do
      {
        team: team.name
      }
    end

    context 'as a contributor of the team that is going to control the namespace' do

      it 'creates a new namespace' do
        sign_in contributor
        post_params = { namespace: valid_attributes, format: :js }

        expect do
          post :create, post_params
        end.to change(Namespace, :count).by(1)
      end

    end

    context 'as a viewer of the team that is going to control the namespace' do

      it 'blocks access' do
        sign_in viewer
        post_params = { namespace: valid_attributes, format: :js }

        expect do
          post :create, post_params
        end.not_to change(Namespace, :count)
        expect(response.status).to eq(401)
      end

    end

    context 'as a generic user not part of the team that is going to control the namespace' do

      it 'blocks access' do
        sign_in create(:user)
        post_params = { namespace: valid_attributes, format: :js }

        expect do
          post :create, post_params
        end.not_to change(Namespace, :count)
        expect(response.status).to eq(401)
      end

    end

    context 'with valid params' do
      before :each do
        sign_in owner
        @post_params = {
          namespace: valid_attributes,
          format: :js
        }
      end

      it 'creates a new Namespace' do
        expect do
          post :create, @post_params
        end.to change(Namespace, :count).by(1)
        expect(assigns(:namespace).team).to eq(team)
      end

      it 'assigns a newly created namespace as @namespace' do
        post :create, @post_params
        expect(assigns(:namespace)).to be_a(Namespace)
        expect(assigns(:namespace)).to be_persisted
      end

    end

    context 'with invalid params' do
      before :each do
        sign_in owner
      end

      it 'assigns a newly created but unsaved namespace as @namespace' do
        post :create, namespace: invalid_attributes, format: :js
        expect(assigns(:namespace)).to be_a_new(Namespace)
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'activity tracking' do
    before :each do
      sign_in owner
    end

    it 'tracks namespace creation' do
      post_params = {
        namespace: { team: team.name, namespace: 'qa_team_namespace' },
        format: :js
      }

      expect do
        post :create, post_params
      end.to change(PublicActivity::Activity, :count).by(1)

      activity = PublicActivity::Activity.last
      expect(activity.key).to eq('namespace.create')
      expect(activity.owner).to eq(owner)
      expect(activity.trackable).to eq(Namespace.last)
    end

    it 'tracks set namespace private' do
      namespace.update_attributes(public: true)

      expect do
        put :toggle_public, id: namespace.id, format: :js
      end.to change(PublicActivity::Activity, :count).by(1)

      activity = PublicActivity::Activity.last
      expect(activity.key).to eq('namespace.private')
      expect(activity.owner).to eq(owner)
      expect(activity.trackable).to eq(namespace)
    end

    it 'tracks set namespace public' do
      namespace.update_attributes(public: false)

      expect do
        put :toggle_public, id: namespace.id, format: :js
      end.to change(PublicActivity::Activity, :count).by(1)

      activity = PublicActivity::Activity.last
      expect(activity.key).to eq('namespace.public')
      expect(activity.owner).to eq(owner)
      expect(activity.trackable).to eq(namespace)
    end
  end
end
