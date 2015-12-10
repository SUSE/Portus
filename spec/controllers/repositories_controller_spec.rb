require "rails_helper"

describe RepositoriesController do

  let(:valid_session) { {} }
  let(:user) { create(:user) }
  let(:personal_namespace) { Namespace.find_by name: user.username }
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

  describe "GET #new" do
    let!(:user_team) { create(:team, owners: [user]) }
    let!(:owned_namespace) { create(:namespace, team: user_team) }
    let(:global_namespace) { Namespace.find_by global: true }

    before :each do
      create(:registry)
      sign_in user
    end

    it "works fine when no namespace is specified" do
      get :new

      expect(assigns(:namespaces)).to include(personal_namespace)
      expect(assigns(:namespaces)).to include(owned_namespace)
      expect(assigns(:namespaces)).not_to include(global_namespace)
      expect(response.status).to eq 200
    end

    it "works fine when the namespace is controlled by the user" do
      get :new, namespace_id: personal_namespace.id

      expect(assigns(:namespaces)).to include(personal_namespace)
      expect(assigns(:namespaces)).to include(owned_namespace)
      expect(assigns(:namespaces)).not_to include(global_namespace)
      expect(response.status).to eq 200
    end

    it "failes to edit a repository not writable by the user" do
      get :new, namespace_id: private_namespace.id

      expect(response.status).to eq 401
    end
  end

  describe "POST #create" do
    let(:source_url) { "https://git.example.com/user/repo.git" }

    before :each do
      create(:registry)
      sign_in user
    end

    it "creates new automated repository" do
      expect do
        post :create, repository: {
          name:         "automated",
          namespace_id: personal_namespace.id,
          source_url:   source_url
        }
      end.to change(Repository, :count).by(1)

      expect(PublicActivity::Activity.count).to eq 1

      activity = PublicActivity::Activity.last
      expect(activity.trackable).to eq(Repository.last)
      expect(activity.parameters[:source_url]).to eq(source_url)
    end

    it "fails to create new repository when the user has no push rights for the target namespace" do
      expect do
        post :create, repository: {
          name:         "automated",
          namespace_id: private_namespace.id,
          source_url:   "https://git.example.com/user/repo.git"
        }
      end.not_to change(Repository, :count)
    end

    it "redirects back to the new page when the registry cannot be saved" do
      repo = create(:repository, namespace: personal_namespace)
      expect do
        post :create, repository: {
          name:         repo.name,
          namespace_id: personal_namespace.id,
          source_url:   "https://git.example.com/user/repo.git"
        }
      end.not_to change(Repository, :count)

      expect(response).to render_template("new")
    end
  end

  describe "GET #edit" do
    let(:controlled_repository) { create(:repository, namespace: personal_namespace) }
    let(:uncontrolled_repository) { create(:repository, namespace: private_namespace) }

    before :each do
      create(:registry)
      sign_in user
    end

    it "allows edit of a controlled repository" do
      get :edit, id: controlled_repository.id

      expect(assigns(:repository)).to eq(controlled_repository)
      expect(response.status).to eq 200
    end

    it "fails to edit a repository not writable by the user" do
      get :edit, id: uncontrolled_repository.id

      expect(response.status).to eq 401
    end
  end

  describe "PUT #update" do
    let(:controlled_repository) { create(:repository, namespace: personal_namespace) }
    let(:uncontrolled_repository) { create(:repository, namespace: private_namespace) }

    before :each do
      create(:registry)
      sign_in user
    end

    it "allows to update a controller repository" do
      new_source_url = "new url"

      expect do
        put :update,
          id:         controlled_repository.id,
          repository: { source_url: new_source_url }

      end.to change(PublicActivity::Activity, :count).by(1)

      activity = PublicActivity::Activity.last
      expect(activity.trackable).to eq(controlled_repository)
      expect(activity.parameters[:old_source]).to eq("")
      expect(activity.parameters[:new_source]).to eq(new_source_url)

      controlled_repository.reload
      expect(controlled_repository.source_url).to eq(new_source_url)
      expect(response).to redirect_to(controlled_repository)
    end

    it "fails to create new repository when the user has no push rights for the target namespace" do
      new_source_url = "new url"

      put :update, id:         uncontrolled_repository.id,
                   repository: { source_url: new_source_url }

      controlled_repository.reload
      expect(controlled_repository.source_url).not_to eq(new_source_url)
      expect(response.status).to eq 401
    end

  end

end
