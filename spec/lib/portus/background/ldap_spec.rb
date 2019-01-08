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

    it "returns false if there are no teams nor users to be checked" do
      APP_CONFIG["ldap"]["enabled"] = true
      create(:team, ldap_group_checked: Team.ldap_statuses[:disabled])
      create(:team, ldap_group_checked: Team.ldap_statuses[:checked])
      User.all.update_all(ldap_group_checked: User.ldap_statuses[:checked])

      expect(subject.work?).to be_falsey
    end

    it "returns true if there are no teams but there are users to be checked" do
      APP_CONFIG["ldap"]["enabled"] = true
      create(:team, ldap_group_checked: Team.ldap_statuses[:disabled])
      create(:team, ldap_group_checked: Team.ldap_statuses[:checked])

      # Because of the onwers automatically created for the above teams.
      expect(subject.work?).to be_truthy
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
      create(:team, name: "t1", ldap_group_checked: Team.ldap_statuses[:disabled])
      create(:team, name: "t2", ldap_group_checked: Team.ldap_statuses[:checked])
      create(:team, name: "t3", ldap_group_checked: Team.ldap_statuses[:checked],
             checked_at: Time.zone.now)
      create(:team, name: "t4", ldap_group_checked: Team.ldap_statuses[:unchecked])

      received = []
      allow_any_instance_of(Team).to receive(:ldap_add_members!) do |t|
        received << t.name
        true
      end

      subject.execute!
      expect(received.sort).to eq %w[t2 t4]
    end

    it "sets as unchecked the proper teams" do
      create(:team, name: "t1", ldap_group_checked: Team.ldap_statuses[:disabled])
      create(:team, name: "t2", ldap_group_checked: Team.ldap_statuses[:checked])
      create(:team, name: "t3", ldap_group_checked: Team.ldap_statuses[:checked],
             checked_at: Time.zone.now)
      create(:team, name: "t4", ldap_group_checked: Team.ldap_statuses[:unchecked])

      received = []
      allow_any_instance_of(Team).to receive(:ldap_add_members!) do |t|
        received << t.name
        true
      end

      subject.execute!
      expect(received.sort).to eq %w[t2 t4]
    end

    it "does not touch hidden teams" do
      create(:registry)

      received = []
      allow_any_instance_of(Team).to receive(:ldap_add_members!) do |t|
        received << t.name
        true
      end

      subject.execute!
      expect(received).to be_empty
      expect(Team.first.ldap_group_checked).to eq Team.ldap_statuses[:disabled]
    end

    it "marks new users" do
      # The idea for this test is that it will mark this new user regardless of
      # what happened before. In other words: plenty of things happened
      # meanwhile (including an #execute!), and then we created this user.
      create(:team, ldap_group_checked: Team.ldap_statuses[:unchecked])
      subject.execute!

      create(:user, username: "u1")

      received = []
      allow_any_instance_of(User).to receive(:ldap_add_as_member!) do |u|
        received << u.username
        true
      end

      subject.execute!
      expect(received).to eq ["u1"]
    end

    it "does not check users that existed when all teams were checked" do
      # The team factory already creates a user which acts as an owner. This is
      # the user being checked.
      create(:team, ldap_group_checked: Team.ldap_statuses[:unchecked])

      received = []
      allow_any_instance_of(User).to receive(:ldap_add_as_member!) do |u|
        received << u.username
        true
      end

      subject.execute!
      expect(received).to be_empty
      expect(User.all.first.ldap_group_checked).to eq User.ldap_statuses[:checked]
    end

    it "never touches the portus user" do
      create(:admin, username: "portus")

      received = []
      allow_any_instance_of(User).to receive(:ldap_add_as_member!) do |u|
        received << u.username
        true
      end

      subject.execute!
      expect(received).to be_empty
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
