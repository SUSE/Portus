# frozen_string_literal: true

require "rails_helper"

describe Api::V2::PingController do
  describe "#ping" do
    context "user authorized" do
      it "responds with 200" do
        sign_in(create(:user))
        get v2_ping_url
        expect(response.status).to eq 200
      end
    end
  end
end
