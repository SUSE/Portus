require 'rails_helper'

describe TeamUser do
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:team)  { create(:team, owners: [user1, user2]) }

  it 'does not return disabled team members' do
    id = team.id
    expect(team.team_users.count).to be 2
    user2.update_attributes(enabled: false)
    team = Team.find(id)
    expect(team.team_users.enabled.count).to be 1
  end
end
