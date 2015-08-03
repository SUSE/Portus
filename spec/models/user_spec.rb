require "rails_helper"

describe User do

  subject { create(:user) }

  it { should validate_uniqueness_of(:email) }
  it { should validate_uniqueness_of(:username) }
  it { should allow_value("test1", "1test").for(:username) }
  it { should_not allow_value("portus", "foo", "1Test", "another_test").for(:username) }

  it "should block user creation when the private namespace is not available" do
    name = "coolname"
    team = create(:team, owners: [subject])
    create(:namespace, team: team, name: name)
    user = build(:user, username: name)
    expect(user.save).to be false
    expect(user.errors.size).to eq(1)
    expect(user.errors.first).to match_array([:username, "cannot be used as name for private namespace"])
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
    let!(:user) { create(:user) }
    let!(:team) { create(:team, owners: [admin], viewers: [user]) }

    it "interacts with Devise as expected" do
      expect(user.active_for_authentication?).to be true
      user.update_attributes(enabled: false)
      expect(user.active_for_authentication?).to be false
    end
  end
end
