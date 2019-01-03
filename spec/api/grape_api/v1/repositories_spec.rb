# frozen_string_literal: true

require "rails_helper"

describe API::V1::Repositories, type: :request do
  let!(:admin) { create(:admin) }
  let!(:user)  { create(:user) }
  let!(:owner) { create(:user) }
  let!(:admin_token) { create(:application_token, user: admin) }
  let!(:owner_token) { create(:application_token, user: owner) }
  let!(:user_token) { create(:application_token, user: user) }
  let!(:team) do
    create(:team,
           name:        "somerandomone",
           description: "lala",
           owners:      [owner],
           viewers:     [user])
  end
  let!(:public_namespace) do
    create(:namespace,
           visibility: Namespace.visibilities[:visibility_public],
           team:       team)
  end

  before do
    @admin_header = build_token_header(admin_token)
    @owner_header = build_token_header(owner_token)
    @user_header = build_token_header(user_token)
  end

  context "GET /api/v1/repositories" do
    context "without data" do
      it "returns an empty list" do
        get "/api/v1/repositories", params: nil, headers: @admin_header

        repositories = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(repositories.length).to eq(0)
      end
    end

    context "with data" do
      before do
        create_list(:repository, 15, namespace: public_namespace)
      end

      it "returns list of all repositories (not paginated)" do
        get "/api/v1/repositories", params: { per_page: 10, all: true }, headers: @admin_header

        repositories = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(repositories.length).to eq(15)
      end

      it "returns list of repositories paginated" do
        get "/api/v1/repositories", params: { per_page: 10 }, headers: @admin_header

        repositories = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(repositories.length).to eq(10)
      end

      it "returns list of repositories paginated (page 2)" do
        get "/api/v1/repositories", params: { page: 2 }, headers: @admin_header

        repositories = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(repositories.length).to eq(0)
      end

      it "returns list of repositories ordered" do
        get "/api/v1/repositories",
            params:  { sort_attr: "id", sort_order: "desc", per_page: 10 },
            headers: @admin_header

        repositories = JSON.parse(response.body)
        repositories.each_slice(2) do |a, b|
          expect(a["id"]).to be > b["id"]
        end
      end
    end
  end

  context "GET /api/v1/repositories/:id" do
    it "returns a team" do
      repository = create(:repository, namespace: public_namespace)
      get "/api/v1/repositories/#{repository.id}", params: nil, headers: @admin_header

      repository_parsed = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(repository_parsed["id"]).to eq(repository.id)
      expect(repository_parsed["name"]).to eq(repository.name)
      expect(repository_parsed["tags"]).to be_nil
    end

    it "returns 404 if it doesn't exist" do
      get "/api/v1/repositories/222", params: nil, headers: @admin_header

      expect(response).to have_http_status(:not_found)
    end
  end

  context "PUT /api/v1/teams/:id" do
    let!(:repository) { create(:repository, namespace: public_namespace) }
    let(:data) do
      {
        name:        "other",
        description: "description"
      }
    end

    it "updates only repository description" do
      put "/api/v1/repositories/#{repository.id}",
          params:  { repository: data },
          headers: @admin_header
      expect(response).to have_http_status(:success)

      r = Repository.find(repository.id)
      expect(r.name).not_to eq(data[:name])
      expect(r.description).to eq(data[:description])
    end

    it "does not allow viewers or contributors to update" do
      put "/api/v1/repositories/#{repository.id}",
          params:  { repository: data },
          headers: @user_header
      expect(response).to have_http_status(:forbidden)
    end

    it "returns status not found" do
      repository_id = Repository.maximum(:id) + 1
      put "/api/v1/repositories/#{repository_id}",
          params:  { repository: data },
          headers: @admin_header
      expect(response).to have_http_status(:not_found)
    end

    it "returns 422 when repository cannot be updated" do
      allow_any_instance_of(repository.class).to receive(:update).and_return(false)

      put "/api/v1/repositories/#{repository.id}",
          params:  { repository: data },
          headers: @admin_header

      expect(response).to have_http_status(:unprocessable_entity)
      allow_any_instance_of(repository.class).to receive(:update).and_call_original
    end

    context "non-admins are allowed to update repositories" do
      it "does allow to change the description by owners" do
        put "/api/v1/repositories/#{repository.id}",
            params:  { repository: data },
            headers: @owner_header
        expect(response).to have_http_status(:success)
      end
    end
  end

  context "GET /api/v1/repositories/:id/tags" do
    it "returns list of reposiroty tags" do
      repository = create(:repository, namespace: public_namespace)
      create(:tag, name: "taggg", repository: repository, digest: "1", author: admin)
      create_list(:tag, 4, repository: repository, digest: "123123", author: admin)
      get "/api/v1/repositories/#{repository.id}/tags", params: nil, headers: @admin_header

      tags = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(tags.length).to eq(5)
    end
  end

  context "GET /api/v1/repositories/:id/tags/:tag_id" do
    it "returns list of reposiroty tags" do
      repository = create(:repository, namespace: public_namespace)
      tag = create(:tag, name: "taggg", repository: repository, digest: "1", author: admin)
      get "/api/v1/repositories/#{repository.id}/tags/#{tag.id}",
          params:  nil,
          headers: @admin_header

      tag_parsed = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(tag_parsed["id"]).to eq(tag.id)
      expect(tag_parsed["name"]).to eq(tag.name)
    end
  end

  context "GET /api/v1/repositories/:id/tags/grouped" do
    it "returns list of reposiroty tags grouped" do
      repository = create(:repository, namespace: public_namespace)
      create(:tag, name: "taggg", repository: repository, digest: "1", author: admin)
      create_list(:tag, 4, repository: repository, digest: "123123", author: admin)
      get "/api/v1/repositories/#{repository.id}/tags/grouped", params: nil, headers: @admin_header

      tags = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(tags.length).to eq(2)

      # The order depends on the update_at property, which might be slightly
      # different depending on how fast creation happened on these tests.
      if tags[0].length == 1
        first  = 0
        second = 1
      else
        first  = 1
        second = 0
      end

      expect(tags[first].length).to eq(1)
      expect(tags[second].length).to eq(4)
    end
  end

  context "DELETE /api/v1/repositories/:id" do
    before do
      APP_CONFIG["delete"]["enabled"] = true
    end

    it "deletes repository" do
      repository = create(:repository, namespace: public_namespace)
      delete "/api/v1/repositories/#{repository.id}", params: nil, headers: @admin_header
      expect(response).to have_http_status(:no_content)
      expect { Repository.find(repository.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "forbids deletion of repository (delete disabled)" do
      APP_CONFIG["delete"]["enabled"] = false
      repository = create(:repository, namespace: public_namespace)
      delete "/api/v1/repositories/#{repository.id}", params: nil, headers: @admin_header
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 422 if unable to remove dependent tag" do
      allow_any_instance_of(Portus::RegistryClient).to receive(:delete) do
        raise ::Portus::RegistryClient::RegistryError, "I AM ERROR."
      end

      repository = create(:repository, namespace: public_namespace)
      create(:tag, name: "taggg", repository: repository, digest: "1", author: admin)
      delete "/api/v1/repositories/#{repository.id}", params: nil, headers: @admin_header
      body = JSON.parse(response.body)
      expect(body["message"]).to include("could not remove taggg tag")
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 if unable to remove repository" do
      repository = create(:repository, namespace: public_namespace)
      allow_any_instance_of(Repository).to receive(:destroy).and_return(false)

      delete "/api/v1/repositories/#{repository.id}", params: nil, headers: @admin_header
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns status 404" do
      delete "/api/v1/repositories/999", params: nil, headers: @admin_header
      expect(response).to have_http_status(:not_found)
    end
  end
end
