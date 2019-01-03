# frozen_string_literal: true

require "rails_helper"
require "portus/background/ldap"

describe ::Portus::Background::LDAP do
  describe "#sleep_value" do
    it "returns always 10" do
      expect(subject.sleep_value).to eq 10
    end
  end

  describe "#work?" do
    it "returns false if LDAP is disabled" do
      APP_CONFIG["ldap"]["enabled"] = false
      expect(subject.work?).to be_falsey
    end

    it "returns false if there are no teams to be checked" do
      APP_CONFIG["ldap"]["enabled"] = true
      create(:team, ldap_group_checked: Team.ldap_statuses[:disabled])
      create(:team, ldap_group_checked: Team.ldap_statuses[:checked])

      expect(subject.work?).to be_falsey
    end

    it "returns true if LDAP is enabled and there are teams to be checked" do
      APP_CONFIG["ldap"]["enabled"] = true
      create(:team, ldap_group_checked: Team.ldap_statuses[:disabled])
      create(:team, ldap_group_checked: Team.ldap_statuses[:checked])
      create(:team, ldap_group_checked: Team.ldap_statuses[:unchecked])

      expect(subject.work?).to be_truthy
    end
  end

  describe "#execute!" do
    it "receives the ldap_add_members! method for teams that need a check" do
      create(:team, ldap_group_checked: Team.ldap_statuses[:disabled])
      create(:team, ldap_group_checked: Team.ldap_statuses[:checked])
      unchecked_team = create(:team, ldap_group_checked: Team.ldap_statuses[:unchecked])

      received = []
      allow_any_instance_of(Team).to receive(:ldap_add_members!) do |t|
        received << t.name
        true
      end

      subject.execute!
      expect(received.size).to eq 1
      expect(received.first).to eq unchecked_team.name
    end

    it "sets as unchecked the proper teams" do
      create(:team, name: "t1", ldap_group_checked: Team.ldap_statuses[:disabled])
      create(:team, name: "t2", ldap_group_checked: Team.ldap_statuses[:checked])
      create(:team, name: "t3", ldap_group_checked: Team.ldap_statuses[:checked], checked_at: Time.zone.now)
      create(:team, name: "t4", ldap_group_checked: Team.ldap_statuses[:unchecked])

      received = []
      allow_any_instance_of(Team).to receive(:ldap_add_members!) do |t|
        received << t.name
        true
      end

      subject.execute!
      expect(received.sort).to eq %w[t2 t4]
    end
  end

  describe "#enabled?" do
    it "returns true if LDAP is enabled" do
      APP_CONFIG["ldap"]["enabled"] = true
      expect(subject.enabled?).to be_truthy
    end

    it "returns false if LDAP is disabled" do
      APP_CONFIG["ldap"]["enabled"] = false
      expect(subject.enabled?).to be_falsey
    end

    it "returns false if LDAP is enabled but group_sync disabled" do
      APP_CONFIG["ldap"]["enabled"] = true
      APP_CONFIG["ldap"]["group_sync"]["enabled"] = false

      expect(subject.enabled?).to be_falsey
    end
  end

  describe "#disable?" do
    it "always returns false" do
      expect(subject.disable?).to be_falsey
    end
  end

  describe "#to_s" do
    it "works" do
      expect(subject.to_s).to eq "LDAP synchronization"
    end
  end
end
