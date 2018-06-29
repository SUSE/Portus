# frozen_string_literal: true

require "rails_helper"

describe "Namespaces support" do
  let!(:registry) { create(:registry) }
  let!(:user) { create(:admin) }
  let!(:user2) { create(:user) }
  let!(:user3) { create(:user) }
  let!(:team) { create(:team, owners: [user], contributors: [user2], viewers: [user3]) }
  let!(:namespace) { create(:namespace, team: team, registry: registry) }

  before do
    login_as user, scope: :user
  end

  describe "Namespaces#index" do
    it "An user cannot submit with invalid form", js: true do
      visit namespaces_path

      find(".toggle-link-new-namespace").click

      expect(page).to have_button("Create", disabled: true)
    end

    it "A user cannot leave name field empty", js: true do
      visit namespaces_path

      find(".toggle-link-new-namespace").click

      fill_in "Name", with: "something"
      clear_field("#namespace_name")

      expect(page).to have_content("Name can't be blank")
      expect(page).to have_button("Create", disabled: true)
    end

    it "A user cannot fill field with an invalid name", js: true do
      visit namespaces_path

      find(".toggle-link-new-namespace").click

      fill_in "Name", with: "!@#!@#"

      expect(page).to have_content("Name can only contain lower case alphanumeric characters")
      expect(page).to have_button("Create", disabled: true)
    end

    # TODO: move this test to a component level one instead of feature once
    # form component is migrated to a vue file
    it "shows team field if no team", js: true do
      visit namespaces_path

      find(".toggle-link-new-namespace").click

      expect(page).to have_css(".namespace_team")
    end

    it "An user cannot create a namespace that already exists", js: true do
      visit namespaces_path

      find(".toggle-link-new-namespace").click

      fill_in "Name", with: Namespace.first.name
      wait_for_ajax

      expect(page).to have_content("Name has already been taken")
      expect(page).to have_button("Create", disabled: true)
    end

    it "An user cannot create a namespace for a hidden team", js: true do
      visit namespaces_path

      find(".toggle-link-new-namespace").click

      fill_in "Name", with: Namespace.first.name
      fill_vue_multiselect(".namespace_team", Team.where(hidden: true).first.name)
      wait_for_ajax

      expect(page).to have_content("Oops! No team found.")
      expect(page).to have_button("Create", disabled: true)
    end

    it "A namespace can be created from the index page", js: true do
      namespaces_count = Namespace.count

      visit namespaces_path
      find(".toggle-link-new-namespace").click

      fill_in "Name", with: "valid-namespace"
      select_vue_multiselect(".namespace_team", namespace.team.name)
      click_button "Create"

      wait_for_ajax

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Namespace 'valid-namespace' was created successfully")

      # Check that it created a link to it and that it's accessible.
      expect(Namespace.count).to eql namespaces_count + 1
      expect(page).to have_link("valid-namespace")
      find(:link, "valid-namespace").click

      namespace = Namespace.find_by(name: "valid-namespace")
      expect(page).to have_current_path(namespace_path(namespace))
    end

    it "The namespace visibility can be changed", js: true do
      visit namespaces_path
      id = namespace.id

      expect(namespace.visibility_private?).to be true
      expect(page).to have_css(".namespace_#{id} .private-btn.btn-primary")

      find(".namespace_#{id} .protected-btn").click
      wait_for_ajax

      expect(page).to have_css(".namespace_#{id} .protected-btn.btn-primary")
      namespace = Namespace.find(id)
      expect(namespace.visibility_protected?).to be true

      find(".namespace_#{id} .public-btn").click
      wait_for_ajax

      expect(page).to have_css(".namespace_#{id} .public-btn.btn-primary")
      namespace = Namespace.find(id)
      expect(namespace.visibility_public?).to be true
    end

    it "Namespace table sorting is reachable through url", js: true do
      # sort asc
      visit namespaces_path(ns_sort_asc: true)

      expect(page).to have_css(".fa-sort-amount-asc")

      # sort desc
      visit namespaces_path(ns_sort_asc: false)

      expect(page).to have_css(".fa-sort-amount-desc")

      # sort asc & created_at
      visit namespaces_path(ns_sort_asc: true, ns_sort_by: "created_at")

      expect(page).to have_css("th:nth-child(4) .fa-sort-amount-asc")

      # sort desc & created_at
      visit namespaces_path(ns_sort_asc: false, ns_sort_by: "created_at")

      expect(page).to have_css("th:nth-child(4) .fa-sort-amount-desc")
    end

    it "URL is updated when namespaces column is sorted", js: true do
      visit namespaces_path

      expect(page).to have_css(".member-namespaces-panel th:nth-child(4)")

      # sort asc & created_at
      find(".member-namespaces-panel th:nth-child(4)").click

      expect(page).to have_css(".member-namespaces-panel th:nth-child(4) .fa-sort-amount-asc")
      path = namespaces_path(ns_sort_asc: true, ns_sort_by: "created_at")
      expect(page).to have_current_path(path)

      # sort desc & created_at
      find(".member-namespaces-panel th:nth-child(4)").click

      expect(page).to have_css(".member-namespaces-panel th:nth-child(4) .fa-sort-amount-desc")
      path = namespaces_path(ns_sort_asc: false, ns_sort_by: "created_at")
      expect(page).to have_current_path(path)
    end

    it "Namespace table pagination is reachable through url", js: true do
      create_list(:namespace, 15, team: team, registry: registry)

      # page 2
      visit namespaces_path(ns_page: 2)

      expect(page).to have_css(".namespaces-panel .pagination li.active:nth-child(3)")

      # page 1
      visit namespaces_path(ns_page: 1)

      expect(page).to have_css(".namespaces-panel .pagination li.active:nth-child(2)")
    end

    it "URL is updated when page is changed", js: true do
      create_list(:namespace, 15, team: team, registry: registry)

      visit namespaces_path

      expect(page).to have_content("Created at")
      expect(page).to have_css(".member-namespaces-panel .pagination li:nth-child(3)")

      # page 2
      find(".member-namespaces-panel .pagination li:nth-child(3) a").click

      expect(page).to have_css(".member-namespaces-panel .pagination li.active:nth-child(3)")
      expect(page).to have_current_path(namespaces_path(ns_page: 2))

      # page 1
      find(".member-namespaces-panel .pagination li:nth-child(2) a").click

      expect(page).to have_css(".member-namespaces-panel .pagination li.active:nth-child(2)")
      expect(page).to have_current_path(namespaces_path(ns_page: 1))
    end
  end

  describe "#update" do
    it "user inputs a team does not exist", js: true do
      visit namespace_path(namespace.id)
      find(".toggle-link-edit-namespace").click

      fill_vue_multiselect(".namespace_team", "unknown")
      wait_for_ajax

      expect(page).to have_content("Oops! No team found.")
    end

    it "user removes the team", js: true do
      visit namespace_path(namespace.id)
      find(".toggle-link-edit-namespace").click

      deselect_vue_multiselect(".namespace_team", namespace.team.name)

      expect(page).to have_content("Team can't be blank")
    end

    it "user updates namespace's team", js: true do
      new_team = create(:team, owners: [user])

      visit namespace_path(namespace.id)
      find(".toggle-link-edit-namespace").click

      select_vue_multiselect(".namespace_team", new_team.name)
      wait_for_ajax

      click_button "Save"

      wait_for_ajax

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Namespace '#{namespace.name}' was updated successfully")
    end

    it "user updates namespace's description", js: true do
      visit namespace_path(namespace.id)
      find(".toggle-link-edit-namespace").click

      fill_in "Description", with: "Cool description"
      wait_for_ajax

      click_button "Save"

      wait_for_ajax

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Cool description")
      expect(page).to have_content("Namespace '#{namespace.name}' was updated successfully")
    end
  end

  describe "#show", js: true do
    it "shows the proper visual aid for each role" do
      visit namespace_path(namespace.id)
      expect(page).to have_content("Push Pull Owner")

      login_as user2, scope: :user
      visit namespace_path(namespace.id)
      expect(page).to have_content("Push Pull Contr.")

      login_as user3, scope: :user
      visit namespace_path(namespace.id)
      expect(page).to have_content("Pull Viewer")
    end

    context "when user_permission.push_images is restricted" do
      before do
        APP_CONFIG["user_permission"]["push_images"]["policy"] = "allow-personal"
      end

      it "shows the proper visual aid for each role" do
        login_as user
        visit namespace_path(namespace.id)
        expect(page).to have_content("Push Pull Owner")

        login_as user2, scope: :user
        visit namespace_path(namespace.id)
        expect(page).not_to have_content("Push Pull Contr.")

        login_as user3, scope: :user
        visit namespace_path(namespace.id)
        expect(page).to have_content("Pull Viewer")
      end
    end
  end
end
