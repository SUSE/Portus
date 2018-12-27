# frozen_string_literal: true

require "rails_helper"

describe "public_activity/team/_remove_member.csv.slim" do
  let!(:admin)    { create(:admin) }
  let!(:user)     { create(:user) }
  let!(:team)     { create(:team, owners: [admin]) }

  before do
    APP_CONFIG["display_name"] = { "enabled" => true }
    @user = create(:user, display_name: "display_name")
    team_user = TeamUser.create(user: @user, team: team, role: "viewer")
    @activity = team_user.create_activity!(:remove_member, admin,
                                           team_user: @user.username,
                                           team:      team.name)
  end

  it "renders the activity properly when the user exists" do
    text = render "public_activity/team/remove_member.csv.slim", activity: @activity

    expect(text).to eq("team,#{team.name},remove member,#{@user.display_username},"\
      "#{admin.display_username},#{@activity.created_at},role viewer\n")
  end

  it "renders the activity even if the user got removed" do
    @user.destroy
    @activity.reload

    text = render "public_activity/team/remove_member.csv.slim", activity: @activity

    expect(text).to eq("team,#{team.name},remove member,#{@user.username}"\
      ",#{admin.display_username},#{@activity.created_at},role viewer\n")
  end
end
