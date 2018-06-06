# frozen_string_literal: true

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

  describe "role within team" do
    it "returns the role of the current user inside of the team" do
      expect(helper.role_within_team(viewer, team)).to eq "Viewer"
    end

    it "returns - for users that are not part of the team" do
      expect(helper.role_within_team(admin, team, "-")).to eq "-"
    end

    it "returns nil for users that are not part of the team and nothing was specified" do
      expect(helper.role_within_team(admin, team)).to be_nil
    end
  end

  describe "team_scope_icon" do
    it "renders with the proper icon for a team with one member" do
      personal_team = create(:team, owners: [owner])
      expect(helper.team_scope_icon(personal_team)).to eq(
        '<i class="fa fa-user fa-lg" title="Personal"></i>'
      )
    end

    it "renders with the proper icon for a team with multiple members" do
      expect(helper.team_scope_icon(team)).to eq(
        '<i class="fa fa-users fa-lg" title="Team"></i>'
      )
    end

    it "renders with the proper icon when a team member has been disabled" do
      guy = create(:user, enabled: false)
      uni_team = create(:team, owners: [owner], viewers: [guy])
      expect(helper.team_scope_icon(uni_team)).to eq(
        '<i class="fa fa-user fa-lg" title="Personal"></i>'
      )
    end
  end
end
