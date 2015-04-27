require 'rails_helper'

describe NamespacePolicy do

  subject { described_class }

  let(:user) { FactoryGirl.create(:user) }
  let(:team) do
    t = FactoryGirl.create(:team, owner: user)
    t.users = [user]
    t
  end
  let(:namespace) { FactoryGirl.create(:namespace, team: team) }

  permissions :pull? do

    it 'allows access to user who is the owner of the team behind namespace' do
      expect(subject).to permit(user, namespace)
    end

    it 'disallows access to user who is not the owner of the team behind namespace' do
      expect(subject).to_not permit(build(:user), namespace)
    end

  end

  permissions :push? do

    it 'allows access to user who is the owner of the team behind namespace' do
      expect(subject).to permit(user, namespace)
    end

    it 'allows access to users that are members of the team behind a namespace' do
      user2 = FactoryGirl.create(:user)
      team.users = [user, user2]
      expect(subject).to permit(user2, namespace)
    end

    it 'disallows access to user who is not the owner of the team behind namespace' do
      expect(subject).to_not permit(build(:user), namespace)
    end

  end

end
