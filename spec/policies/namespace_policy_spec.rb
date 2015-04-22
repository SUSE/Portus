require 'rails_helper'

describe NamespacePolicy do

  subject { described_class }

  let(:user) { build(:user) }
  let(:team) { build(:team, owner: user) }
  let(:namespace) { build(:namespace, team: team) }

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

    it 'disallows access to user who is not the owner of the team behind namespace' do
      expect(subject).to_not permit(build(:user), namespace)
    end

  end

end
