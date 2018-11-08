# frozen_string_literal: true

require "rails_helper"

describe "/v2 ping" do
  let(:auth_mech) { ActionController::HttpAuthentication::Basic }
  let(:password) { "this is a test" }
  let(:user) { create(:user, password: password) }
  # TODO: de-dup with tokens api spec
  let(:valid_auth_header) do
    { "HTTP_AUTHORIZATION" => auth_mech.encode_credentials(user.username, password) }
  end
  let(:invalid_auth_header) do
    { "HTTP_AUTHORIZATION" => auth_mech.encode_credentials(user.username, "wrong") }
  end

  it "returns 200 in case of valid auth" do
    get v2_ping_url, params: { service: "test", account: "account" }, headers: valid_auth_header
    expect(response.status).to eq 200
  end

  it "returns 401 in case of invalid auth" do
    get v2_ping_url, params: { service: "test", account: "account" }, headers: invalid_auth_header
    expect(response.status).to eq 401
  end
end
