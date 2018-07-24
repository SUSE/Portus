# frozen_string_literal: true

require "rails_helper"

describe "Dashboard page" do
  let!(:registry) { create(:registry) }
  let!(:user) { create(:admin, display_name: "docker-gangsta") }
  let!(:team) { create(:team, owners: [user]) }
  let!(:namespace) { create(:namespace, team: team, registry: registry) }
  let!(:repository) { create(:repository, namespace: namespace) }
  let!(:starred_repo) { create(:repository, namespace: namespace) }
  let!(:star) { create(:star, user: user, repository: starred_repo) }
  let!(:personal_namespace) { user.namespace }
  let!(:personal_repository) { create(:repository, namespace: personal_namespace) }

  let!(:regular_user) { create(:user) }
  let!(:another_user) { create(:admin) }
  let!(:another_team) { create(:team, owners: [another_user]) }
  let!(:another_team2) { create(:team, owners: [another_user]) }
  let!(:public_namespace) do
    create(:namespace,
           team:       another_team,
           registry:   registry,
           visibility: Namespace.visibilities[:visibility_public])
  end
  let!(:public_repository) { create(:repository, namespace: public_namespace) }
  let!(:protected_namespace) do
    create(:namespace,
           team:       another_team2,
           registry:   registry,
           visibility: Namespace.visibilities[:visibility_protected])
  end
  let!(:protected_repository) { create(:repository, namespace: protected_namespace) }

  before do
    login_as user
    visit authenticated_root_path
  end

  describe "Portus user" do
    it "The dashboard does not count the Portus user" do
      User.create_portus_user!
      visit authenticated_root_path

      # 4 users: user, another_user, regular_user, and the one created by the registry.
      expect(find(".users span").text).to eq "4"
    end

    it "warns the admin that the portus user does not exist" do
      expect(page).to have_content("The Portus user does not exist!")

      User.create_portus_user!
      visit authenticated_root_path

      expect(page).not_to have_content("The Portus user does not exist!")
    end
  end

  describe "Recent activities", js: true do
    context "when admin" do
      it "shows 'View all activities' link" do
        expect(page).to have_content("View all activities")
      end

      it "shows 'Personal' activities by default" do
        within(".recent-activities-panel") do
          expect(page).to have_link("Personal")
        end
      end

      it "shows 'Admin' activities tab" do
        within(".recent-activities-panel") do
          expect(page).to have_link("Admin")
        end
      end
    end

    context "when regular user" do
      before do
        login_as regular_user
        visit authenticated_root_path
      end

      it "doesn't show 'View all activities' link" do
        expect(page).not_to have_content("View all activities")
      end

      it "doesn't show 'Personal' activities tab" do
        within(".recent-activities-panel") do
          expect(page).not_to have_link("Personal")
        end
      end

      it "doesn't show 'Admin' activities tab" do
        within(".recent-activities-panel") do
          expect(page).not_to have_link("Admin")
        end
      end
    end
  end

  describe "Repositories sidebar" do
    it "Show all the repositories user has access to" do
      expect(page).to have_content("#{personal_namespace.name}/#{personal_repository.name}")
      expect(page).to have_content("#{namespace.name}/#{repository.name}")
      expect(page).to have_content("#{namespace.name}/#{starred_repo.name}")
      expect(page).to have_content("#{public_namespace.name}/#{public_repository.name}")
      expect(page).to have_content("#{protected_namespace.name}/#{protected_repository.name}")
    end

    it "Show personal repositories", js: true do
      within("#repositories_sidebar") do
        click_link("Personal")
      end

      expect(page).to have_content("#{personal_namespace.name}/#{personal_repository.name}")
      expect(page).not_to have_content("#{namespace.name}/#{starred_repo.name}")
      expect(page).not_to have_content("#{namespace.name}/#{repository.name}")
      expect(page).not_to have_content("#{public_namespace.name}/#{public_repository.name}")
      expect(page).not_to have_content("#{protected_namespace.name}/#{protected_repository.name}")
    end

    it "Show personal repositories", js: true do
      click_link("Starred")

      expect(page).to have_content("#{namespace.name}/#{starred_repo.name}")
      expect(page).not_to have_content("#{personal_namespace.name}/#{personal_repository.name}")
      expect(page).not_to have_content("#{namespace.name}/#{repository.name}")
      expect(page).not_to have_content("#{public_namespace.name}/#{public_repository.name}")
      expect(page).not_to have_content("#{protected_namespace.name}/#{protected_repository.name}")
    end
  end

  describe "Display name" do
    it "Shows the display name of the user when needed" do
      expect(page).not_to have_content("docker-gangsta")
      APP_CONFIG["display_name"] = { "enabled" => true }
      visit authenticated_root_path
      expect(page).to have_content("docker-gangsta")
    end
  end
end
