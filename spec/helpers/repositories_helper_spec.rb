require 'rails_helper'

RSpec.describe RepositoriesHelper, type: :helper do

  let(:admin)       { create(:admin) }
  let(:owner)       { create(:user) }
  let(:viewer)      { create(:user) }
  let(:contributor) { create(:user) }
  let(:team) do
    create(:team,
           owners: [owner],
           contributors: [contributor],
           viewers: [viewer])
  end
  let(:namespace) { create(:namespace, team: team) }
  let(:repository) { create(:repository, namespace: namespace) }
  let(:starred_repository) { create(:repository, namespace: namespace) }
  let(:owner_star) {create(:star, repository: starred_repository, user: owner)}
  let(:viewer_star) {create(:star, repository: starred_repository, user: viewer)}
  let(:contributor_star) {create(:star, repository: starred_repository, user: contributor)}

  describe 'can_star_repository?' do
    it 'returns true if current user has not starred repo`' do
      sign_in owner
      expect(helper.can_star_repository?(repository)).to be true
    end
    it 'returns false if current user has already starred repo`' do
      sign_in owner
      owner_star
      expect(helper.can_star_repository?(starred_repository)).to be false
    end
  end
end
