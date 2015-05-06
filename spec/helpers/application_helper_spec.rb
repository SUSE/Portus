require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do

  let(:owner)       { create(:user) }
  let(:viewer)      { create(:user) }
  let(:contributor) { create(:user) }
  let(:team) do
    create(:team,
           owners: [ owner ],
           contributors: [ contributor ],
           viewers: [ viewer ])
  end
  let(:namespace) { create(:namespace, team: team) }

  describe 'is_namespace_owner?' do
    it 'returns true if current user is an owner of the namespace' do
      sign_in owner
      expect(helper.is_namespace_owner?(namespace)).to be true
    end

    it 'returns false if current user is a viewer of the namespace' do
      sign_in viewer
      expect(helper.is_namespace_owner?(namespace)).to be false
    end

    it 'returns false if current user is a contributor of the namespace' do
      sign_in contributor
      expect(helper.is_namespace_owner?(namespace)).to be false
    end
  end

end
