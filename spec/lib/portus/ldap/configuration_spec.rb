# frozen_string_literal: true

require "rails_helper"

describe ::Portus::LDAP::Configuration do
  before do
    APP_CONFIG["ldap"]["enabled"] = true
  end

  context "enabled?" do
    it "returns false if LDAP is disabled" do
      APP_CONFIG["ldap"]["enabled"] = false
      params = { user: { username: "name", password: "1234" } }
      cfg = ::Portus::LDAP::Configuration.new(params)
      expect(cfg.enabled?).to be_falsey
      expect(cfg.reason_message).to eq "LDAP is not enabled"
    end

    it "returns false if we are talking about the portus user" do
      cfg = ::Portus::LDAP::Configuration.new(account: "portus", password: "1234")
      expect(cfg.enabled?).to be_falsey
      expect(cfg.reason_message).to eq "Portus user does not go through LDAP"
    end

    it "returns false if the user is a bot" do
      create(:user, username: "bot", bot: true)
      params = { user: { username: "bot", password: "" } }
      cfg = ::Portus::LDAP::Configuration.new(params)
      expect(cfg.enabled?).to be_falsey
      expect(cfg.reason_message).to eq "Bot user is not expected to be present on LDAP"
    end

    it "returns true otherwise" do
      params = { user: { username: "name", password: "" } }
      cfg = ::Portus::LDAP::Configuration.new(params)
      expect(cfg.enabled?).to be_truthy
      expect(cfg.reason_message).to eq ""
    end
  end

  context "initialized?" do
    it "returns false if the given parameters are empty" do
      cfg = ::Portus::LDAP::Configuration.new({})
      expect(cfg.initialized?).to be_falsey
    end

    it "returns false if the password is empty" do
      params = { user: { username: "name", password: "" } }
      cfg = ::Portus::LDAP::Configuration.new(params)
      expect(cfg.initialized?).to be_falsey
    end

    it "returns false if the password is empty" do
      params = { user: { username: "", password: "1234" } }
      cfg = ::Portus::LDAP::Configuration.new(params)
      expect(cfg.initialized?).to be_falsey
    end

    it "returns true if both parameters are set" do
      params = { user: { username: "name", password: "1234" } }
      cfg = ::Portus::LDAP::Configuration.new(params)
      expect(cfg.initialized?).to be_truthy
    end
  end
end
