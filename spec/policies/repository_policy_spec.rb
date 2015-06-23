require 'rails_helper'

describe RepositoryPolicy do

  subject { described_class }

  let(:registry)    { create(:registry) }
  let(:user)        { create(:user) }
  let(:user2)       { create(:user) }
  let(:team)        { create(:team, owners: [user]) }
  let(:team2)       { create(:team, owners: [user2]) }

  describe 'scope' do

    before :each do
      public_namespace = create(:namespace, team: team2, public: true, registry: registry)
      @public_repository = create(:repository, namespace: public_namespace)

      private_namespace = create(:namespace, team: team2, registry: registry)
      @private_repository = create(:repository, namespace: private_namespace)

      namespace = create(:namespace, team: team, registry: registry)
      @repository = create(:repository, namespace: namespace)
    end

    it 'include repositories that are part of public namespaces' do
      expect(Pundit.policy_scope(user, Repository).to_a).to include(@public_repository)
    end

    it 'include repositories that are part of namespace controlled by a team to which the user belongs' do
      expect(Pundit.policy_scope(user, Repository).to_a).to include(@repository)
    end

    it 'never shows repositories inside of private namespaces' do
      expect(Pundit.policy_scope(user, Repository).to_a).not_to include(@private_repository)
    end

  end

end
