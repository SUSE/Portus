require 'rails_helper'

describe User do

  subject { create(:user) }

  it { should validate_uniqueness_of(:email) }
  it { should validate_uniqueness_of(:username) }

  describe '#create_personal_namespace!' do

    it 'creates a team and a namespace with the name of username' do
      subject.create_personal_namespace!
      team = Team.find_by!(name: subject.username)
      Namespace.find_by!(name: subject.username)
      tu = TeamUser.find_by!(user: subject, team: team)
      assert tu.owner
    end

  end

end
