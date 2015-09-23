require "rails_helper"

RSpec.describe Admin::RegistriesController, type: :controller do
  let(:admin) { create(:admin) }

  before :each do
    sign_in admin
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end

    it "returns a 404 if there's already a registry in place" do
      create(:registry)
      expect { get :new }.to raise_error(ActionController::RoutingError)
    end
  end

  describe "POST #create" do
    context "no registry" do
      it "creates a new registry" do
        expect do
          post :create, registry: attributes_for(:registry)
        end.to change(Registry, :count).by(1)
      end

      it "assigns the freshly created registry to all the existing namespaces" do
        3.times { create(:team) }

        post :create, registry: attributes_for(:registry)
        registry = Registry.last

        Namespace.all.each { |n| expect(n.registry).to eq(registry) }
      end
    end

    context "one registry already exists" do
      it "does not create a new registry" do
        create(:registry)

        expect do
          post :create, registry: attributes_for(:registry)
        end.to raise_error(ActionController::RoutingError)
      end
    end

    context "wrong params" do
      it "redirects to the new page" do
        expect do
          post :create, registry: { name: "foo" }
        end.to change(Registry, :count).by(0)
      end
    end
  end

  describe "PUT #update" do
    let!(:registry) { create(:registry) }

    it "does nothing if the registry was not found" do
      expect do
        put :update, id: registry.id + 1, format: :js
      end.to raise_error(ActiveRecord::RecordNotFound)
      expect(Registry.first.use_ssl).to be_falsey
    end

    it "registry found" do
      put :update, id: registry.id, format: :js
      expect(Registry.first.use_ssl).to be_truthy
    end
  end
end
