# frozen_string_literal: true

require "rails_helper"

describe "public_activity/team/_remove_member" do
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
    render "public_activity/team/remove_member", activity: @activity

    text = assert_select(".description h6").text
    expect(text).to eq("#{admin.display_username} removed user '" \
                       "#{@user.display_username}' from the #{team.name} team")
  end

  it "renders the activity even if the user got removed" do
    @user.destroy
    @activity.reload

    render "public_activity/team/remove_member", activity: @activity

    text = assert_select(".description h6").text
    expect(text).to eq("#{admin.display_username} removed user '" \
                       "#{@user.username}' from the #{team.name} team")
  end
end
