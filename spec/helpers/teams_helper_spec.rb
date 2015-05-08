require 'rails_helper'

RSpec.describe TeamsHelper, type: :helper do

  let(:owner)       { create(:user) }
  let(:viewer)      { create(:user) }
  let(:contributor) { create(:user) }
  let(:team) do
    create(:team,
           owners: [ owner ],
           contributors: [ contributor ],
           viewers: [ viewer ])
  end

  describe 'is_team_owner?' do
    it 'returns true if current user is an owner of the team' do
      sign_in owner
      expect(helper.is_team_owner?(team)).to be true
    end

    it 'returns false if current user is a viewer of the team' do
      sign_in viewer
      expect(helper.is_team_owner?(team)).to be false
    end

    it 'returns false if current user is a contributor of the team' do
      sign_in contributor
      expect(helper.is_team_owner?(team)).to be false
    end
  end

  describe 'role within team' do
    it 'returns the role of the current user inside of the team' do
      sign_in viewer
      expect(helper.role_within_team(team)).to eq 'Viewer'
    end

    it 'returns - for users that are not part of the team' do
      sign_in create(:user, admin: true)
      expect(helper.role_within_team(team)).to eq '-'
    end
  end
end
