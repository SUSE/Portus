require "rails_helper"

describe API::V1::Registries do
  before :each do
    admin = create :admin
    token = create :application_token, user: admin
    @header = build_token_header(token)
  end

  context "GET /api/v1/registries" do
    it "returns list of registries" do
      r = create :registry
      get "/api/v1/registries", nil, @header
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
      get "/api/v1/registries/validate", registry_data, @header

      data = JSON.parse(response.body)
      expect(data["messages"]["hostname"]).to be_falsey
      expect(data["valid"]).to be_truthy
    end

    it "returns unreachable accordingly" do
      allow_any_instance_of(Registry).to receive(:reachable?).and_return("Error message")
      get "/api/v1/registries/validate", registry_data, @header

      data = JSON.parse(response.body)
      expect(data["messages"]["hostname"]).to eq(["Error message"])
      expect(data["valid"]).to be_falsey
    end

    it "returns an error when the name is already taken" do
      create :registry, name: registry_data[:name]

      allow_any_instance_of(Registry).to receive(:reachable?).and_return("Error message")
      get "/api/v1/registries/validate", registry_data, @header

      data = JSON.parse(response.body)
      expect(data["messages"]["name"]).to eq(["has already been taken"])
      expect(data["valid"]).to be_falsey
    end
  end
end
