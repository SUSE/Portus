require 'rails_helper'

describe RepositoryPolicy do

  subject { described_class }

  let(:user) { build(:user) }
  let(:team) { build(:team, owner: user) }
  let(:repository) { build(:repository, team: team) }

  permissions :pull? do

    it 'allows access to user who is the owner of the team behind repository' do
      expect(subject).to permit(user, repository)
    end

    it 'disallows access to user who is not the owner of the team behind repository' do
      expect(subject).to_not permit(build(:user), repository)
    end

  end

  permissions :push? do

    it 'allows access to user who is the owner of the team behind repository' do
      expect(subject).to permit(user, repository)
    end

    it 'disallows access to user who is not the owner of the team behind repository' do
      expect(subject).to_not permit(build(:user), repository)
    end

  end

end
