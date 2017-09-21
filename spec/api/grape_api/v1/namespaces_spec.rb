require "rails_helper"

describe API::V1::Namespaces do
  let!(:admin) { create(:admin) }
  let!(:token) { create(:application_token, user: admin) }
  let!(:team) { create(:team, owners: [admin]) }
  let!(:public_visibility) { Namespace.visibilities[:visibility_public] }

  before :each do
    @header = { "PORTUS-AUTH" => "#{token.user.username}:#{token.application}" }
  end

  context "GET /api/v1/namespaces" do
    it "returns an empty list" do
      get "/api/v1/namespaces", nil, @header

      namespaces = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(namespaces.length).to eq(0)
    end

    it "returns list of accessible namespaces" do
      # global + personal + below
      create(:namespace, visibility: public_visibility, team: team)
      get "/api/v1/namespaces", nil, @header

      namespaces = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(namespaces.length).to eq(3)
    end
  end

  context "GET /api/v1/namespaces/:id" do
    it "returns a namespace" do
      namespace = create(:namespace, visibility: public_visibility, team: team)
      get "/api/v1/namespaces/#{namespace.id}", nil, @header

      namespace_parsed = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(namespace_parsed["id"]).to eq(namespace.id)
      expect(namespace_parsed["name"]).to eq(namespace.name)
    end

    it "returns 404 if it doesn't exist" do
      get "/api/v1/namespaces/222", nil, @header

      expect(response).to have_http_status(:not_found)
    end
  end

  context "GET /api/v1/namespaces/:id/repositories" do
    it "returns list of repositories from a namespace" do
      namespace = create(:namespace, visibility: public_visibility, team: team)
      repository = create(:repository, namespace: namespace)
      get "/api/v1/namespaces/#{namespace.id}/repositories", nil, @header

      repositories = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(repositories.length).to eq(1)
      expect(repositories[0]["id"]).to eq(repository.id)
      expect(repositories[0]["name"]).to eq(repository.name)
    end
  end
end
