# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionsHelper, type: :helper do
  describe "#social_login" do
    it "display social buttons" do
      APP_CONFIG["oauth"] = { "google_oauth2" => { "enabled" => true } }
      expect(helper.social_login).to match(/Social logins/)
    end
  end
end
