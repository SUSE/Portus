require "rails_helper"

describe HelpController, type: :controller do
  describe "GET #index" do
    let!(:registry)   { create(:registry, hostname: "registry.test.lan") }
    let!(:user)       { create(:admin) }

    before :each do
      sign_in user
      request.env["HTTP_REFERER"] = "/"
    end

    it "returns the page successfully" do
      get :index
      expect(response.code.to_i).to eq 200
    end
  end
end
