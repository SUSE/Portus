require "rails_helper"

RSpec.describe ExploreController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      APP_CONFIG["anonymous_browsing"] = { "enabled" => true }

      get :index
      expect(response).to have_http_status(:success)
    end

    it "redirects if the feature is not enabled" do
      APP_CONFIG["anonymous_browsing"] = { "enabled" => false }

      get :index
      expect(response).to have_http_status(:found)
    end
  end
end
