# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  username               :string(255)      default(""), not null
#  email                  :string(255)      default("")
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  admin                  :boolean          default(FALSE)
#  enabled                :boolean          default(TRUE)
#  ldap_name              :string(255)
#  failed_attempts        :integer          default(0)
#  locked_at              :datetime
#  namespace_id           :integer
#  display_name           :string(255)
#  provider               :string(255)
#  uid                    :string(255)
#  bot                    :boolean          default(FALSE)
#  ldap_group_checked     :integer          default(0)
#
# Indexes
#
#  index_users_on_display_name          (display_name) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_namespace_id          (namespace_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#

require "rails_helper"

describe User do
  subject { create(:user) }

  it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
  it { is_expected.to validate_uniqueness_of(:username) }
  it { is_expected.to allow_value("test1", "1test").for(:username) }

  describe "#private_namespace_and_team_available" do
    it "adds an error if the username cannot produce a valid namespace" do
      user = build(:user, username: "!!!!!")
      expect(user.save).to be false
      expect(user.errors.size).to eq(1)
      expect(user.errors.first)
        .to match_array([:username, "'!!!!!' cannot be transformed into a " \
          "valid namespace name"])
    end

    it "works beautifully if everything was fine" do
      name = "coolname"
      team = create(:team, owners: [subject])
      create(:namespace, team: team, name: "somethingelse")

      user = build(:user, username: name)
      expect(user.save).to be_truthy
      expect(user.errors).to be_empty
    end
  end

  describe "after creation" do
    it "does not create a namespace if it's a bot" do
      create(:registry)

      user = create(:user)
      expect(user.namespace).to_not be_nil
      bot = create(:user, bot: true)
      expect(bot.namespace).to be_nil
    end
  end

  it "#email_required?" do
    expect(subject.email_required?).to be true

    APP_CONFIG["ldap"]["enabled"] = true
    incomplete = create(:user, email: "")

    expect(subject.email_required?).to be true
    expect(incomplete.email_required?).to be false
  end

  it "calls create_personal_team! on a user" do
    create(:registry)
    expect(Namespace.find_by(name: "test")).to be nil

    user2 = create(:user, username: "test")
    namespace = Namespace.find_by(name: "test")
    expect(namespace).not_to be nil
    expect(user2.namespace.id).to eq namespace.id
  end

  describe ".find_from_event" do
    let!(:user)   { create(:user, username: "username001") }

    it "find user by username" do
      APP_CONFIG["ldap"]["enabled"] = false
      event = { "actor" => { "name" => "username001" } }
      expect(described_class.find_from_event(event)).not_to be_nil
    end
  end

  describe "#create_without_password" do
    it "allows us to create a user without a password" do
      u, c = User.create_without_password(username: "test", email: "test@test.org", admin: true)

      expect(c).to be_truthy
      expect(u.encrypted_password).to be_blank
    end

    it "does not create a user if one of the parameters is wrong" do
      _, c = User.create_without_password(username: "test", email: "test", admin: true)

      expect(c).to be_falsey
      expect(User.find_by(username: "test")).to be_nil
    end
  end

  describe ".create_portus_user" do
    it "creates the portus user" do
      described_class.create_portus_user!
      expect(User.first.username).to eq "portus"
    end

    it "sets `skip_portus_validation` back to nil" do
      described_class.create_portus_user!
      expect(User.skip_portus_validation).to be_nil
    end

    it "does not create a namespace or a team because there's no registry" do
      described_class.create_portus_user!
      expect(Team.count).to eq 0
      expect(Namespace.count).to eq 0
    end
  end

  describe "#portus_user_validation" do
    it "does nothing if the portus user was simply touched" do
      described_class.create_portus_user!
      portus = User.find_by(username: "portus")

      portus.touch
      expect(portus.errors.any?).to be_falsey
    end

    it "does nothing if the portus user has a new team" do
      User.delete_all
      described_class.create_portus_user!

      r = Registry.new(name: "r", hostname: "registry.mssola.cat:5000", use_ssl: true)
      r.save!

      portus = User.find_by(username: "portus")
      expect(portus.namespace).not_to be_nil
      expect(portus.namespace.team).not_to be_nil
    end
  end

  describe "#create_personal_namespace!" do
    context "no registry defined yet" do
      before do
        expect(Registry.count).to be(0)
      end

      it "does nothing" do
        subject.create_personal_namespace!

        expect(Team.find_by(name: subject.username)).to be(nil)
        expect(Namespace.find_by(name: subject.username)).to be(nil)
      end
    end

    context "registry defined" do
      before do
        create(:admin)
        create(:registry)
      end

      it "creates a team and a namespace with the name of username" do
        subject.create_personal_namespace!
        team = Team.find_by!(name: subject.username)
        Namespace.find_by!(name: subject.username)
        TeamUser.find_by!(user: subject, team: team)
        expect(team.owners).to include(subject)
        expect(team).to be_hidden
      end

      it "creates a namespace with the modified username" do
        user = build(:user, username: "name_")
        expect(user.save).to be_truthy
        Namespace.find_by!(name: "name")
      end
    end
  end

  describe "admins" do
    let!(:admin1) { create(:admin) }
    let!(:admin2) { create(:admin, enabled: false) }

    it "computes the right amount of admin users" do
      admins = described_class.admins
      expect(admins.count).to be 1
      expect(admins.first.id).to be admin1.id
    end
  end

  describe "#toggle_admin" do
    let!(:registry) { create(:registry) }
    let!(:user) { create(:user) }

    it "Toggles the admin attribute" do
      # We have a registry and the admin user is the owner.
      admin = described_class.where(admin: true).first
      owners = registry.global_namespace.team.owners
      expect(owners.count).to be(1)
      expect(owners.first.id).to be(admin.id)

      # Now we set the new user as another admin.
      user.toggle_admin!
      owners = registry.global_namespace.team.owners
      expect(user.admin?).to be true
      expect(owners.count).to be(2)

      # Now we remove it as an admin again
      user.toggle_admin!
      owners = registry.global_namespace.team.owners
      expect(owners.count).to be(1)
      expect(owners.first.id).to be(admin.id)
    end
  end

  describe "disabling" do
    let!(:admin) { create(:admin) }
    let!(:user)  { create(:user) }
    let!(:team)  { create(:team, owners: [admin], viewers: [user]) }

    it "interacts with Devise as expected" do
      expect(user.active_for_authentication?).to be true
      user.update(enabled: false)
      expect(user.active_for_authentication?).to be false
    end

    context "LDAP-only user" do
      it "cannot log in if LDAP is disabled" do
        APP_CONFIG["ldap"]["enabled"] = false

        user.update(encrypted_password: "")
        expect(user.active_for_authentication?).to be_falsey
        expect(user.inactive_message).to eq "This user can only login through an LDAP server."
      end

      it "can log in if LDAP is enabled" do
        APP_CONFIG["ldap"]["enabled"] = true

        user.update(encrypted_password: "")
        expect(user.active_for_authentication?).to be_truthy
      end
    end
  end

  describe "#toggle_enabled!" do
    let!(:admin) { create(:admin) }
    let!(:user)  { create(:user)  }

    describe "target user is enabled" do
      let!(:another) { create(:user) }

      it "does not allow the only admin to disable itself" do
        # portus is not a "real" admin, so it shouldn't count.
        create(:admin, username: "portus")
        expect(admin.toggle_enabled!(admin)).to be false
        expect(admin.enabled?).to be true
      end

      it "does not allow to disable the portus user" do
        portus = create(:admin, username: "portus")
        expect(admin.toggle_enabled!(portus)).to be false
        expect(portus.enabled?).to be true
      end

      it "does not allow to disable another user if current is not admin" do
        expect(user.toggle_enabled!(another)).to be false
        expect(another.enabled?).to be true
      end

      it "allows to disable another user if admin" do
        expect(admin.toggle_enabled!(another)).to be true
        expect(another.enabled?).to be false
      end

      it "allows to disable itself if there are more admins" do
        another_admin = create(:admin)
        expect(admin.toggle_enabled!(another_admin)).to be true
        expect(another_admin.enabled?).to be false
      end

      it "allows to disable itself if it's a regular user" do
        expect(user.toggle_enabled!(user)).to be true
        expect(user.enabled?).to be false
      end
    end

    describe "target user is disabled" do
      it "only allows admin users to enable users back" do
        disabled = create(:user, enabled: false)

        expect(user.toggle_enabled!(disabled)).to be false
        expect(disabled.enabled?).to be false

        expect(admin.toggle_enabled!(disabled)).to be true
        expect(disabled.enabled?).to be true
      end
    end
  end

  describe "#application_token_valid?" do
    let(:user) { create(:user) }

    it "returns false when there are no tokens" do
      expect(user.application_token_valid?("foo")).to be false
    end

    it "returns true when there's a token matching" do
      # the factory uses appication's name as plain token
      create(:application_token, application: "good", user: user)
      create(:application_token, application: "bad", user: user)
      expect(user.application_token_valid?("good")).to be true
    end

    it "returns false when there's no token matching" do
      # the factory uses appication's name as plain token
      create(:application_token, application: "bad", user: user)
      expect(user.application_token_valid?("good")).to be false
    end
  end

  describe "#display_username" do
    let(:user)  { build(:user, username: "user", display_name: "display") }
    let(:user2) { build(:user, username: "user") }

    it "returns the username of the feature is disabled" do
      expect(user.display_username).to eq user.username
    end

    it "returns the username/display_name if the feature is enabled" do
      APP_CONFIG["display_name"] = { "enabled" => true }
      expect(user2.display_username).to eq user.username
      expect(user.display_username).to eq user.display_name
    end
  end

  describe "#avatar_url" do
    let(:user) { build(:user, username: "user") }
    let(:user2) { build(:user, username: "user", email: "") }

    it "returns nil if the feature is disabled" do
      expect(user.avatar_url).to be_nil
    end

    it "returns nil if email is blank" do
      expect(user2.avatar_url).to be_nil
    end

    it "returns the avatar url if the feature is enabled" do
      APP_CONFIG["gravatar"] = { "enabled" => true }
      expect(user.avatar_url).to start_with("http")
    end
  end

  describe "#destroy" do
    let!(:registry)   { create(:registry, hostname: "registry.test.lan") }
    let!(:user)       { create(:admin, username: "admin") }
    let!(:user2)      { create(:user, username: "user") }
    let!(:repo)       { create(:repository, namespace: registry.global_namespace, name: "repo") }
    let!(:tag)        { create(:tag, name: "t", repository: repo, user_id: user.id, digest: "1") }

    it "updates tags being owned by this user on destroy" do
      create(:tag, name: "tag", repository: repo, digest: "1")
      user.destroy

      t = Tag.find_by(name: "t")
      expect(t.user_id).to be_nil
      expect(t.username).to eq "admin"
    end
  end

  describe "#suggest_username" do
    it "selects a username until it finds a proper one" do
      create(:user, username: "username")
      user = build(:user)
      name = user.suggest_username("nickname" => "username")
      expect(name).to eq "username_01"
    end
  end

  describe "#ldap_add_as_member!" do
    it "adds a member" do
      allow_any_instance_of(::Portus::LDAP::Search).to(
        receive(:user_groups).and_return(["newteam"])
      )

      t = create(:team, name: "newteam", owners: [create(:user, username: "user")])
      u = create(:user)

      expect { u.ldap_add_as_member! }.to(
        change { u.ldap_group_checked }
          .from(User.ldap_statuses[:unchecked])
          .to(User.ldap_statuses[:checked])
      )
      expect(t.viewers.map(&:username)).to eq [u.username]
    end

    it "doesn't do anything if the team doesn't exist" do
      allow_any_instance_of(::Portus::LDAP::Search).to(
        receive(:user_groups).and_return(["newteam"])
      )
      received = 0
      allow_any_instance_of(Team).to receive(:add_team_member!) do
        received += 1
      end

      u = create(:user)
      u.ldap_add_as_member!
      expect(received).to eq 0
      expect(u.ldap_group_checked).to eq User.ldap_statuses[:checked]
    end

    it "doesn't do anything if the team is marked as disabled" do
      allow_any_instance_of(::Portus::LDAP::Search).to(
        receive(:user_groups).and_return(["newteam"])
      )
      received = 0
      allow_any_instance_of(Team).to receive(:add_team_member!) do
        received += 1
      end

      create(:team,
             name:               "newteam",
             owners:             [create(:user, username: "user")],
             ldap_group_checked: Team.ldap_statuses[:disabled])

      u = create(:user)
      u.ldap_add_as_member!
      expect(received).to eq 0
      expect(u.ldap_group_checked).to eq User.ldap_statuses[:checked]
    end

    it "doesn't do anything if the user is already a member" do
      allow_any_instance_of(::Portus::LDAP::Search).to(
        receive(:user_groups).and_return(["newteam"])
      )

      u = create(:user)
      t = create(:team, name: "newteam", owners: [u])
      expect { t.users.size }.not_to(
        change { u.ldap_add_as_member! }
      )
      expect(u.ldap_group_checked).to eq User.ldap_statuses[:checked]
    end

    it "doesn't do anything when no groups have been returned" do
      allow_any_instance_of(::Portus::LDAP::Search).to(receive(:user_groups).and_return([]))
      received = 0
      allow_any_instance_of(Team).to receive(:add_team_member!) do
        received += 1
      end

      create(:team, name: "newteam", owners: [create(:user, username: "user")])
      u = create(:user)
      u.ldap_add_as_member!
      expect(received).to eq 0
      expect(u.ldap_group_checked).to eq User.ldap_statuses[:checked]
    end
  end
end
