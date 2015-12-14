require "rails_helper"

describe User do
  subject { create(:user) }

  it { should validate_uniqueness_of(:email) }
  it { should validate_uniqueness_of(:username) }
  it { should allow_value("test1", "1test").for(:username) }

  it "should block user creation when the private namespace is not available" do
    name = "coolname"
    team = create(:team, owners: [subject])
    create(:namespace, team: team, name: name)
    user = build(:user, username: name)
    expect(user.save).to be false
    expect(user.errors.size).to eq(1)
    expect(user.errors.first)
      .to match_array([:username, "cannot be used as name for private namespace"])
  end

  it "#email_required?" do
    expect(subject.email_required?).to be true

    APP_CONFIG["ldap"] = { "enabled" => true }
    incomplete = create(:user, email: "", ldap_name: "user")

    expect(subject.email_required?).to be true
    expect(incomplete.email_required?).to be false
  end

  it "calls create_personal_team! on a user" do
    create(:registry)
    expect(Namespace.find_by(name: "test")).to be nil

    create(:user, username: "test")
    expect(Namespace.find_by(name: "test")).to_not be nil
  end

  describe ".find_from_event" do
    let!(:user)   { create(:user, username: "username001", ldap_name: "user@domain.com") }

    context "LDAP is enabled" do
      it "find user by ldap_name" do
        APP_CONFIG["ldap"] = { "enabled" => true }
        event = { "actor" => { "name" => "user@domain.com" } }
        expect(User.find_from_event(event)).not_to be_nil
      end
    end

    context "LDAP is disabled" do
      it "find user by username" do
        APP_CONFIG["ldap"] = { "enabled" => false }
        event = { "actor" => { "name" => "username001" } }
        expect(User.find_from_event(event)).not_to be_nil
      end
    end
  end

  describe "#create_personal_namespace!" do
    context "no registry defined yet" do
      before :each do
        expect(Registry.count).to be(0)
      end

      it "does nothing" do
        subject.create_personal_namespace!

        expect(Team.find_by(name: subject.username)).to be(nil)
        expect(Namespace.find_by(name: subject.username)).to be(nil)
      end

    end

    context "registry defined" do
      before :each do
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
    end
  end

  describe "admins" do
    let!(:admin1) { create(:admin) }
    let!(:admin2) { create(:admin, enabled: false) }

    it "computes the right amount of admin users" do
      admins = User.admins
      expect(admins.count).to be 1
      expect(admins.first.id).to be admin1.id
    end
  end

  describe "#toggle_admin" do
    let!(:registry) { create(:registry) }
    let!(:user) { create(:user) }

    it "Toggles the admin attribute" do
      # We have a registry and the admin user is the owner.
      admin = User.where(admin: true).first
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
      user.update_attributes(enabled: false)
      expect(user.active_for_authentication?).to be false
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
end
