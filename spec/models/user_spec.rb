require 'rails_helper'

describe User do

  subject { build(:user) }

  it { should validate_uniqueness_of(:email) }
  it { should validate_uniqueness_of(:username) }

  describe '#create_personal_repository!' do

    it 'creates a team with the name of username' do
      expect(Team).to receive(:find_or_create_by!).with(name: subject.username, owner: subject)
      subject.create_personal_repository!
    end

    it 'creates a repository under a team with the name of username' do
      expect(Repository).to receive(:create!).with(name: subject.username, team: instance_of(Team))
      subject.create_personal_repository!
    end

  end

end
