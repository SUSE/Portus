# frozen_string_literal: true

require "rails_helper"

describe RepositoriesController do
  let(:user) { create(:user) }
  let!(:public_namespace) do
    create(:namespace,
           visibility: Namespace.visibilities[:visibility_public],
           team:       create(:team))
  end
  let!(:visible_repository) { create(:repository, namespace: public_namespace) }
  let!(:private_namespace) do
    create(:namespace,
           visibility: Namespace.visibilities[:visibility_private],
           team:       create(:team))
  end
  let!(:invisible_repository) { create(:repository, namespace: private_namespace) }

  before do
    sign_in user
  end

  describe "GET #show" do
    it "assigns the requested repository as @repository" do
      get repository_url(visible_repository.to_param)
      expect(assigns(:repository)).to eq(visible_repository)
    end
  end

  describe "POST #toggle_star" do
    it "Succeeds when calling star" do
      repository = create(:repository, namespace: public_namespace)
      post toggle_star_repository_url(repository.id), params: { format: :json }

      expect(assigns(:repository)).to eq(repository)
      expect(response.status).to eq 200
    end

    it "Succeeds when calling unstar" do
      repository = create(:repository, :starred, namespace: public_namespace)
      post toggle_star_repository_url(repository.id), params: { format: :json }

      expect(assigns(:repository)).to eq(repository)
      expect(response.status).to eq 200
    end

    it "returns 422 when fails to star/unstar" do
      allow_any_instance_of(Repository).to receive(:toggle_star).and_return(false)
      repository = create(:repository, namespace: public_namespace)
      post toggle_star_repository_url(repository.id), params: { format: :json }

      expect(response.status).to eq 422
    end
  end
end
