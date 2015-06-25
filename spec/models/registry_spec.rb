require 'rails_helper'

RSpec.describe Registry, type: :model do

  it { should have_many(:namespaces) }

  describe '#create_global_namespace' do
    it 'adds all existing admins to the global team' do
      # NOTE: the :registry factory already creates an admin
      create(:user, admin: true)
      registry = create(:registry)

      owners = registry.global_namespace.team.owners.order('username ASC')
      users = User.where(admin: true).order('username ASC')

      expect(owners.count).to be(2)
      expect(users).to match_array(owners)
    end
  end
end
