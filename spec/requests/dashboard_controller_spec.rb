# frozen_string_literal: true

require "rails_helper"

RSpec.describe DashboardController do
  let(:user) { create(:user) }

  before do
    create(:registry)
    sign_in user
  end

  describe "GET #index" do
    it "returns http success" do
      get authenticated_root_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "Headers" do
    it "sets the X-UA-Compatible header" do
      get authenticated_root_url
      expect(response.headers["X-UA-Compatible"]).to eq("IE=edge")
    end
  end

  describe "Authentication through application tokens" do
    before do
      sign_out user
    end

    it "redirects to sign in if no token" do
      get root_url
      expect(response).to render_template(:new)
    end

    it "goes through if a valid application token is passed" do
      other = create(:user)
      create(:application_token, application: "application", user: other)

      get "/", headers: { "PORTUS-AUTH" => "#{other.username}:application" }
      expect(response).to have_http_status(:success)
    end
  end
end
