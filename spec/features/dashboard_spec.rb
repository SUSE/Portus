require "rails_helper"

feature "Dashboard page" do
  let!(:registry) { create(:registry) }
  let!(:user) { create(:admin) }
  let!(:team) { create(:team, owners: [user]) }
  let!(:namespace) { create(:namespace, team: team) }
  let!(:repository) { create(:repository, namespace: namespace) }
  let!(:starred_repo) { create(:repository, namespace: namespace) }
  let!(:star) { create(:star, user: user, repository: starred_repo) }
  let!(:personal_namespace) { Namespace.find_by(name: user.username) }
  let!(:personal_repository) { create(:repository, namespace: personal_namespace) }

  let!(:another_user) { create(:admin) }
  let!(:another_team) { create(:team, owners: [another_user]) }
  let!(:public_namespace) { create(:namespace, team: another_team, public: true) }
  let!(:public_repository) { create(:repository, namespace: public_namespace) }

  before do
    login_as user, scope: :user
  end

  describe "Repositories sidebar" do
    scenario "Show all the repositories user has access to", js: true do
      visit authenticated_root_path
      expect(page).to have_content("#{personal_namespace.name}/#{personal_repository.name}")
      expect(page).to have_content("#{namespace.name}/#{repository.name}")
      expect(page).to have_content("#{namespace.name}/#{starred_repo.name}")
      expect(page).to have_content("#{public_namespace.name}/#{public_repository.name}")
    end

    scenario "Show personal repositories", js: true do
      visit authenticated_root_path
      click_link("Personal")
      wait_for_effect_on(".tab-content")

      expect(page).to have_content("#{personal_namespace.name}/#{personal_repository.name}")
      expect(page).not_to have_content("#{namespace.name}/#{starred_repo.name}")
      expect(page).not_to have_content("#{namespace.name}/#{repository.name}")
      expect(page).not_to have_content("#{public_namespace.name}/#{public_repository.name}")
    end

    scenario "Show personal repositories", js: true do
      visit authenticated_root_path
      click_link("Starred")
      wait_for_effect_on(".tab-content")

      expect(page).to have_content("#{namespace.name}/#{starred_repo.name}")
      expect(page).not_to have_content("#{personal_namespace.name}/#{personal_repository.name}")
      expect(page).not_to have_content("#{namespace.name}/#{repository.name}")
      expect(page).not_to have_content("#{public_namespace.name}/#{public_repository.name}")
    end
  end
end
