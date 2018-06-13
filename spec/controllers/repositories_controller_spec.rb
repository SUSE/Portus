# frozen_string_literal: true

# == Schema Information
#
# Table name: repositories
#
#  id           :integer          not null, primary key
#  name         :string(255)      default(""), not null
#  namespace_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  marked       :boolean          default(FALSE)
#
# Indexes
#
#  index_repositories_on_name_and_namespace_id  (name,namespace_id) UNIQUE
#  index_repositories_on_namespace_id           (namespace_id)
#

require "rails_helper"

describe RepositoriesController, type: :controller do
  let(:valid_session) { {} }
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
      repository = create(:repository, namespace: public_namespace)
      post :toggle_star, { id: repository.id, format: :json }, valid_session

      expect(assigns(:repository)).to eq(repository)
      expect(response.status).to eq 200
    end

    it "Succeeds when calling unstar" do
      repository = create(:repository, :starred, namespace: public_namespace)
      post :toggle_star, { id: repository.id, format: :json }, valid_session

      expect(assigns(:repository)).to eq(repository)
      expect(response.status).to eq 200
    end

    it "returns 422 when fails to star/unstar" do
      allow_any_instance_of(Repository).to receive(:toggle_star).and_return(false)
      repository = create(:repository, namespace: public_namespace)
      post :toggle_star, { id: repository.id, format: :json }, valid_session

      expect(response.status).to eq 422
    end
  end
end
