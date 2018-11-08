# frozen_string_literal: true

require "rails_helper"

describe API::V1::Users, type: :request do
  before do
    @admin = create :admin
    token = create :application_token, user: @admin
    @header = build_token_header(token)

    APP_CONFIG["first_user_admin"] = { "enabled" => true }
  end

  context "GET /api/v1/users/:id/application_tokens" do
    it "returns list of user's tokens" do
      user = create :user
      create_list :application_token, 5, user: user
      get "/api/v1/users/#{user.id}/application_tokens", params: nil, headers: @header
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq 5
    end

    it "returns status 404" do
      user_id = User.maximum(:id) + 1
      get "/api/v1/users/#{user_id}/application_tokens", params: nil, headers: @header
      expect(response).to have_http_status(:not_found)
    end
  end

  context "POST /api/v1/users/:id/application_tokens" do
    it "creates user's token" do
      user = create :user
      post "/api/v1/users/#{user.id}/application_tokens",
           params: { application: "test" }, headers: @header
      expect(response).to have_http_status(:success)
      expect(ApplicationToken.count).to eq 2
      expect(JSON.parse(response.body)).not_to be_nil
    end

    it "returns errors on existing application" do
      token = create :application_token

      post "/api/v1/users/#{token.user_id}/application_tokens",
           params: { application: token.application }, headers: @header
      expect(response).to have_http_status(:unprocessable_entity)

      resp = JSON.parse(response.body)
      expect(resp["message"]["application"].first).to eq("has already been taken")
    end

    it "returns server error" do
      token = create :application_token
      post "/api/v1/users/#{token.user_id}/application_tokens",
           params: { application: nil }, headers: @header
      expect(response).to have_http_status(:internal_server_error)
    end

    it "returns a 400 for malformed JSON" do
      user = create :user

      @header = @header.merge(
        "CONTENT_TYPE" => "application/json",
        "ACCEPT"       => "application/json"
      )
      post "/api/v1/users/#{user.id}/application_tokens", params: "{", headers: @header
      expect(response).to have_http_status(:bad_request)

      resp = JSON.parse(response.body)
      expect(resp["message"]).to match(%r{When specifying application/json as content-type})
    end
  end

  context "DELETE /api/v1/users/application_tokens/:id" do
    it "deletes application_token" do
      token = create(:application_token, user: @admin)
      delete "/api/v1/users/application_tokens/#{token.id}", params: nil, headers: @header
      expect(response).to have_http_status(:no_content)
      expect { ApplicationToken.find(token.id) }.to \
        raise_exception(ActiveRecord::RecordNotFound)
    end

    it "deletes bot application token if admin" do
      bot = create(:user, bot: true)
      token = create(:application_token, user: bot)
      delete "/api/v1/users/application_tokens/#{token.id}", params: nil, headers: @header
      expect(response).to have_http_status(:no_content)
      expect { ApplicationToken.find(token.id) }.to \
        raise_exception(ActiveRecord::RecordNotFound)
    end

    it "returns status 404" do
      token_id = ApplicationToken.maximum(:id) + 1
      delete "/api/v1/users/application_tokens/#{token_id}", params: nil, headers: @header
      expect(response).to have_http_status(:not_found)
    end

    it "returns status 403 if it's not the token's owner" do
      user = create :user
      token = create(:application_token, user: user)
      delete "/api/v1/users/application_tokens/#{token.id}", params: nil, headers: @header
      expect(response).to have_http_status(:forbidden)
    end
  end

  it "DELETE /api/v1/users/:id/application_tokens/:id returns status 404" do
    user = create :user
    token = create :application_token, user: user
    delete "/api/v1/users/#{user.id}/application_tokens/#{token.id}", params: nil, headers: @header
    expect(response).to have_http_status(:not_found)
  end
end
