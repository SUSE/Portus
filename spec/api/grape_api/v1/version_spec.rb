require "rails_helper"

describe API::Version do
  let!(:admin) { create(:admin) }
  let!(:token) { create(:application_token, user: admin) }

  before :each do
    @header = build_token_header(token)
  end

  context "GET /api/version" do
    it "returns the proper versioning" do
      expect(::Version).to receive(:git?).and_return(true)

      get "/api/version", nil, @header

      resp = JSON.parse(response.body)
      expect(resp["api-versions"]).to eq(["v1"])
      expect(resp["version"]).to eq(::Version.from_file)
      expect(resp["git"]).to_not include("tag")
    end

    it "returns the tag when present" do
      expect(::Version).to receive(:git?).and_return(true)
      expect(::Version::TAG).to receive(:present?).and_return(true)

      get "/api/version", nil, @header

      resp = JSON.parse(response.body)
      expect(resp["git"]).to include("tag")
    end

    it "returns a null git on stable releases" do
      expect(::Version).to receive(:git?).and_return(false)

      get "/api/version", nil, @header

      resp = JSON.parse(response.body)
      expect(resp["api-versions"]).to eq(["v1"])
      expect(resp["version"]).to eq(::Version.from_file)
      expect(resp["git"]).to be_nil
    end
  end
end
