require "rails_helper"

RSpec.describe TeamsHelper, type: :helper do

  let(:admin)       { create(:admin) }
  let(:owner)       { create(:user) }
  let(:viewer)      { create(:user) }
  let(:contributor) { create(:user) }
  let(:team) do
    create(:team,
           owners:       [owner],
           contributors: [contributor],
           viewers:      [viewer])
  end

  describe "can_manage_team?" do
    it "returns true if current user is an owner of the team" do
      sign_in owner
      expect(helper.can_manage_team?(team)).to be true
    end

    it "returns false if current user is a viewer of the team" do
      sign_in viewer
      expect(helper.can_manage_team?(team)).to be false
    end

    it "returns false if current user is a contributor of the team" do
      sign_in contributor
      expect(helper.can_manage_team?(team)).to be false
    end

    it "returns false if current user is an admin even if he is not related with the team" do
      sign_in admin
      expect(helper.can_manage_team?(team)).to be true
    end
  end

  describe "role within team" do
    it "returns the role of the current user inside of the team" do
      sign_in viewer
      expect(helper.role_within_team(team)).to eq "Viewer"
    end

    it "returns - for users that are not part of the team" do
      sign_in create(:admin)
      expect(helper.role_within_team(team)).to eq "-"
    end
  end
end
