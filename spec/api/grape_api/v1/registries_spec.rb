# frozen_string_literal: true

require "rails_helper"

describe API::V1::Registries, type: :request do
  before do
    admin = create :admin
    token = create :application_token, user: admin
    @header = build_token_header(token)
  end

  context "POST /api/v1/registries" do
    let(:data) do
      {
        registry: {
          name:     "registry",
          hostname: "my.registry.cat",
          use_ssl:  true
        }
      }
    end

    let(:wrong_data) do
      {
        registry: {
          name:     "registry",
          hostname: "my.registry.cat",
          use_ssl:  "asd"
        }
      }
    end

    it "creates a registry" do
      allow_any_instance_of(Registry).to receive(:reachable?).and_return(nil)
      post "/api/v1/registries", params: data, headers: @header
      expect(response).to have_http_status(:success)

      resp = JSON.parse(response.body)
      expect(resp["name"]).to eq(data[:registry][:name])
    end

    it "returns a 400 for malformed JSON" do
      allow_any_instance_of(Registry).to receive(:reachable?).and_return(nil)

      @header = @header.merge("CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json")
      post "/api/v1/registries", params: "{", headers: @header
      expect(response).to have_http_status(:bad_request)

      resp = JSON.parse(response.body)
      expect(resp["message"]).to match(%r{When specifying application/json as content-type})
    end

    it "does not create a registry on a wrong use_ssl value" do
      allow_any_instance_of(Registry).to receive(:reachable?).and_return(nil)
      post "/api/v1/registries", params: wrong_data, headers: @header
      expect(response).to have_http_status(:bad_request)

      resp = JSON.parse(response.body)
      msg = resp["message"].first.last.first
      expect(msg).to eq("is invalid")
    end

    it "does not allow to create multiple registries" do
      create :registry

      allow_any_instance_of(Registry).to receive(:reachable?).and_return(nil)
      post "/api/v1/registries", params: data, headers: @header
      expect(response).to have_http_status(:unprocessable_entity)

      resp = JSON.parse(response.body)
      expect(resp["message"]["uniqueness"].first).to eq("You can only create one registry")
    end

    it "returns an error on unreachable registry" do
      allow_any_instance_of(Registry).to receive(:reachable?).and_return("Not reachable")
      post "/api/v1/registries", params: data, headers: @header
      expect(response).to have_http_status(:unprocessable_entity)

      resp = JSON.parse(response.body)
      expect(resp["message"]["hostname"].first).to eq("Not reachable")
    end
  end

  context "PUT /api/v1/registries/:id" do
    let(:data) do
      {
        registry: {
          name:     "registry",
          hostname: "my.registry.cat",
          use_ssl:  true
        }
      }
    end

    let(:just_name) do
      { registry: { name: "newname" } }
    end

    it "updates a registry" do
      r = create :registry, hostname: "lala"

      allow_any_instance_of(Registry).to receive(:reachable?).and_return(nil)
      put "/api/v1/registries/#{r.id}", params: data, headers: @header
      expect(response).to have_http_status(:success)

      reg  = Registry.first
      resp = JSON.parse(response.body)

      expect(resp["hostname"]).to eq(data[:registry][:hostname])
      expect(reg.hostname).to eq(data[:registry][:hostname])
    end

    it "does not allow to update the hostname if there are repositories" do
      r = create :registry
      namespace = create(:namespace, registry: r, team: create(:team))
      create(:repository, namespace: namespace)

      allow_any_instance_of(Registry).to receive(:reachable?).and_return(nil)
      put "/api/v1/registries/#{r.id}", params: data, headers: @header
      expect(response).to have_http_status(:unprocessable_entity)

      resp = JSON.parse(response.body)
      msg  = "Registry is not empty, cannot change hostname"
      expect(resp["message"]["hostname"].first).to eq(msg)
    end

    it "allows to update if there are repositories and you don't touch the hostname" do
      r = create :registry
      namespace = create(:namespace, registry: r, team: create(:team))
      create(:repository, namespace: namespace)

      allow_any_instance_of(Registry).to receive(:reachable?).and_return(nil)
      put "/api/v1/registries/#{r.id}", params: just_name, headers: @header
      expect(response).to have_http_status(:success)

      reg  = Registry.first
      resp = JSON.parse(response.body)
      expect(resp["name"]).to eq(just_name[:registry][:name])
      expect(reg.name).to eq(just_name[:registry][:name])
    end

    it "returns an error on unreachable registry" do
      r = create :registry, hostname: "lala"

      allow_any_instance_of(Registry).to receive(:reachable?).and_return("Not reachable")
      put "/api/v1/registries/#{r.id}", params: data, headers: @header
      expect(response).to have_http_status(:unprocessable_entity)

      resp = JSON.parse(response.body)
      expect(resp["message"]["hostname"].first).to eq("Not reachable")
    end
  end

  context "GET /api/v1/registries" do
    it "returns list of registries" do
      r = create :registry
      get "/api/v1/registries", params: nil, headers: @header
      expect(response).to have_http_status(:success)

      data = JSON.parse(response.body)
      expect(data.first["name"]).to eq(r.name)
    end
  end

  context "GET /api/v1/registries/validate" do
    let(:registry_data) do
      {
        name:     "registry",
        hostname: "my.registry.cat",
        use_ssl:  true
      }
    end

    it "returns valid on a proper registry" do
      allow_any_instance_of(Registry).to receive(:reachable?).and_return(nil)
      get "/api/v1/registries/validate", params: registry_data, headers: @header

      data = JSON.parse(response.body)
      expect(data["messages"]["hostname"]).to be_falsey
      expect(data["valid"]).to be_truthy
    end

    it "returns unreachable accordingly" do
      allow_any_instance_of(Registry).to receive(:reachable?).and_return("Error message")
      get "/api/v1/registries/validate", params: registry_data, headers: @header

      data = JSON.parse(response.body)
      expect(data["messages"]["hostname"]).to eq(["Error message"])
      expect(data["valid"]).to be_falsey
    end

    it "returns an error when the name is already taken" do
      create :registry, name: registry_data[:name]

      allow_any_instance_of(Registry).to receive(:reachable?).and_return("Error message")
      get "/api/v1/registries/validate", params: registry_data, headers: @header

      data = JSON.parse(response.body)
      expect(data["messages"]["name"]).to eq(["has already been taken"])
      expect(data["valid"]).to be_falsey
    end
  end
end
