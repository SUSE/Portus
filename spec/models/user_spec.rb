require 'rails_helper'

describe User do

  subject { build(:user) }

  it { should validate_uniqueness_of(:email) }
  it { should validate_uniqueness_of(:username) }

  describe '#create_personal_namespace!' do

    it 'creates a team and a namespace with the name of username' do
      user = FactoryGirl.create(:user)
      user.create_personal_namespace!
      team = Team.find_by!(name: user.username)
      Namespace.find_by!(name: user.username)
      TeamUser.find_by!(user: user, team: team)
    end

  end

end
