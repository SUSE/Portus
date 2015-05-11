require 'spec_helper'

describe TeamPolicy do

  subject { described_class }

  let(:admin) { create(:user, admin: true) }
  let(:member) { create(:user) }
  let(:team) { create(:team, owners: [ member ]) }

  permissions :is_member? do

    it 'denies access to a user who is not part of the team' do
      expect(subject).to_not permit(create(:user), team)
    end

    it 'allows access to a member of the team' do
      expect(subject).to permit(member, team)
    end

    it 'allows access to an admin even if he is not part of the team' do
      expect(subject).to permit(admin, team)
    end

  end

  describe 'scope' do
    it 'returns only teams having the user as a memeber' do
      # Another team not related with 'owner'
      create(:team, owners: [ create(:user) ])
      expect(Pundit.policy_scope(member, Team).to_a).to match_array(member.teams)
    end
  end

end
