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
      expect(find("#toggle_star")).to be_visible
      find("#toggle_star").click
      wait_for_ajax
      expect(current_path).to eq repository_path(repository)

      # See the response.
      repo = Repository.find(repository.id)
      expect(find("#star-counter")).to have_content("1")
      expect(repo.stars.count).to be 1
    end

    scenario "A user can unstar a repository", js: true do
      visit repository_path(starred_repo)
      expect(find("#toggle_star")).to be_visible
      find("#toggle_star").click
      wait_for_ajax
      expect(current_path).to eq repository_path(starred_repo)

      # See the response.
      repo = Repository.find(repository.id)
      expect(find("#star-counter")).to have_content("0")
      expect(repo.stars.count).to be 0
    end

    scenario "Groupped tags are handled properly", js: true do
      ["", "", "same", "same", "another", "yet-another"].each_with_index do |digest, idx|
        create(:tag, name: "tag#{idx}", author: user, repository: repository, digest: digest)
      end

      expect = [["tag0"], ["tag1"], ["tag2", "tag3"], ["tag4"], ["tag5"]]

      visit repository_path(repository)
      page.all(".tags tr").each_with_index do |row, idx|
        # Skip the header.
        next if idx == 0

        expect[idx - 1].each { |tag| expect(row.text.include?(tag)).to be_truthy }
      end
    end
  end
end
