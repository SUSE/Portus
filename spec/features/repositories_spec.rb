require "rails_helper"

feature "Repositories support" do
  let!(:registry) { create(:registry) }
  let!(:user) { create(:admin) }
  let!(:team) { create(:team, owners: [user]) }
  let!(:namespace) { create(:namespace, team: team) }
  let!(:repository) { create(:repository, namespace: namespace) }
  let!(:starred_repo) { create(:repository, namespace: namespace) }
  let!(:star) { create(:star, user: user, repository: starred_repo) }

  before do
    login_as user, scope: :user
  end

  describe "repository#show" do
    scenario "A user can star a repository", js: true do
      visit repository_path(repository)

      # The form appears after clicking the "Add namespace" link.
      expect(find("#star_repo")).to be_visible
      find("#star_repo").click
      wait_for_ajax
      expect(current_path).to eq repository_path(repository)

      # See the response.
      repo = Repository.find(repository.id)
      expect(page).to have_css("#unstar_repo")
      expect(find("#star-counter")).to have_content("1")
      expect(repo.stars.count).to be 1
    end

    scenario "A user can unstar a repository", js: true do
      visit repository_path(starred_repo)

      # The form appears after clicking the "Add namespace" link.
      expect(find("#unstar_repo")).to be_visible
      find("#unstar_repo").click
      wait_for_ajax
      expect(current_path).to eq repository_path(starred_repo)

      # See the response.
      repo = Repository.find(repository.id)
      expect(page).to have_css("#star_repo")
      expect(find("#star-counter")).to have_content("0")
      expect(repo.stars.count).to be 0
    end
  end
end
