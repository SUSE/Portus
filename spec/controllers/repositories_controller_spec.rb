require "rails_helper"

describe RepositoriesController do

  let(:valid_session) { {} }
  let(:user) { create(:user) }
  let!(:public_namespace) { create(:namespace, public: 1, team: create(:team)) }
  let!(:visible_repository) { create(:repository, namespace: public_namespace) }
  let!(:private_namespace) { create(:namespace, public: 0, team: create(:team)) }
  let!(:invisible_repository) { create(:repository, namespace: private_namespace) }

  before :each do
    sign_in user
  end

  describe "GET #index" do

    it "assigns all repositories as @repositories" do
      get :index, {}, valid_session
      expect(assigns(:repositories)).to eq([visible_repository])
    end

  end

  describe "GET #show" do

    it "assigns the requested repository as @repository" do
      get :show, { id: visible_repository.to_param }, valid_session
      expect(assigns(:repository)).to eq(visible_repository)
    end
  end

  describe "POST #toggle_star" do
    it "Succeeds when calling star" do
      repository = create(:repository)
      post :toggle_star, { id: repository.to_param, format: :erb }, valid_session

      expect(assigns(:repository)).to eq(repository)
      expect(response.status).to eq 200
    end

    it "Succeeds when calling unstar" do
      repository = create(:repository, :starred)
      post :toggle_star, { id: repository.to_param, format: :erb }, valid_session

      expect(assigns(:repository)).to eq(repository)
      expect(response.status).to eq 200
    end
  end
end
