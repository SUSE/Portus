require "rails_helper"

feature "Namespaces support" do
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
    scenario "An user cannot submit with invalid form", js: true do
      visit namespaces_path

      find(".toggle-link-new-namespace").click
      wait_for_effect_on("#new-namespace-form")

      expect(page).to have_button("Create", disabled: true)
    end

    scenario "A user cannot leave name field empty", js: true do
      visit namespaces_path

      find(".toggle-link-new-namespace").click
      wait_for_effect_on("#new-namespace-form")

      fill_in "Name", with: Namespace.first.name
      fill_in "Name", with: ""

      expect(page).to have_content("Name can't be blank")
      expect(page).to have_button("Create", disabled: true)
    end

    scenario "A user cannot fill field with an invalid name", js: true do
      visit namespaces_path

      find(".toggle-link-new-namespace").click
      wait_for_effect_on("#new-namespace-form")

      fill_in "Name", with: "!@#!@#"

      expect(page).to have_content("Name can only contain lower case alphanumeric characters")
      expect(page).to have_button("Create", disabled: true)
    end

    scenario "An user cannot create a namespace that already exists", js: true do
      visit namespaces_path

      find(".toggle-link-new-namespace").click
      wait_for_effect_on("#new-namespace-form")

      fill_in "Name", with: Namespace.first.name
      wait_for_ajax

      expect(page).to have_content("Name has already been taken")
      expect(page).to have_button("Create", disabled: true)
    end

    scenario "An user cannot create a namespace for a hidden team", js: true do
      visit namespaces_path

      find(".toggle-link-new-namespace").click
      wait_for_effect_on("#new-namespace-form")

      fill_in "Name", with: Namespace.first.name
      fill_in "Team", with: Team.where(hidden: true).first.name
      wait_for_ajax

      expect(page).to have_content("Selected team does not exist")
      expect(page).to have_button("Create", disabled: true)
    end

    scenario "A namespace can be created from the index page", js: true do
      namespaces_count = Namespace.count

      visit namespaces_path
      find(".toggle-link-new-namespace").click
      wait_for_effect_on("#new-namespace-form")

      fill_in "Name", with: "valid-namespace"
      fill_in "Team", with: namespace.team.name
      click_button "Create"

      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Namespace 'valid-namespace' was created successfully")

      # Check that it created a link to it and that it's accessible.
      expect(Namespace.count).to eql namespaces_count + 1
      expect(page).to have_link("valid-namespace")
      find(:link, "valid-namespace").trigger(:click)

      namespace = Namespace.find_by(name: "valid-namespace")
      expect(page).to have_current_path(namespace_path(namespace))
    end

    scenario 'The "Create new namespace" link has a toggle effect', js: true do
      visit namespaces_path
      expect(page).to have_css(".toggle-link-new-namespace i.fa-plus-circle")
      expect(page).to_not have_css(".toggle-link-new-namespace i.fa-minus-circle")

      find(".toggle-link-new-namespace").click
      wait_for_effect_on("#new-namespace-form")

      expect(page).to_not have_css(".toggle-link-new-namespace i.fa-plus-circle")
      expect(page).to have_css(".toggle-link-new-namespace i.fa-minus-circle")

      find(".toggle-link-new-namespace").click
      wait_for_effect_on("#new-namespace-form")

      expect(page).to have_css(".toggle-link-new-namespace i.fa-plus-circle")
      expect(page).to_not have_css(".toggle-link-new-namespace i.fa-minus-circle")
    end

    scenario 'The "Create new namespace" keeps icon after add new namespace', js: true do
      visit namespaces_path
      expect(page).to have_css(".toggle-link-new-namespace i.fa-plus-circle")
      expect(page).to_not have_css(".toggle-link-new-namespace i.fa-minus-circle")

      find(".toggle-link-new-namespace").click
      wait_for_effect_on("#new-namespace-form")

      fill_in "Name", with: "valid-namespace"
      fill_in "Team", with: namespace.team.name

      expect(page).to_not have_css(".toggle-link-new-namespace i.fa-plus-circle")
      expect(page).to have_css(".toggle-link-new-namespace i.fa-minus-circle")

      click_button "Create"
      wait_for_ajax
      wait_for_effect_on("#new-namespace-form")

      expect(page).to have_css(".toggle-link-new-namespace i.fa-plus-circle")
      expect(page).to_not have_css(".toggle-link-new-namespace i.fa-minus-circle")
    end

    scenario "The namespace visibility can be changed", js: true do
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

    scenario "Namespace table sorting is reachable through url", js: true do
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

    scenario "URL is updated when namespaces column is sorted", js: true do
      visit namespaces_path

      expect(page).to have_css(".namespaces-panel:last-of-type th:nth-child(4)")

      # sort asc & created_at
      find(".namespaces-panel:last-of-type th:nth-child(4)").click

      expect(page).to have_css(".namespaces-panel th:nth-child(4) .fa-sort-amount-asc")
      path = namespaces_path(ns_sort_asc: true, ns_sort_by: "created_at")
      expect(page).to have_current_path(path)

      # sort desc & created_at
      find(".namespaces-panel:last-of-type th:nth-child(4)").click

      expect(page).to have_css(".namespaces-panel th:nth-child(4) .fa-sort-amount-desc")
      path = namespaces_path(ns_sort_asc: false, ns_sort_by: "created_at")
      expect(page).to have_current_path(path)
    end

    scenario "Namespace table pagination is reachable through url", js: true do
      create_list(:namespace, 15, team: team, registry: registry)

      # page 2
      visit namespaces_path(ns_page: 2)

      expect(page).to have_css(".namespaces-panel .pagination li.active:nth-child(3)")

      # page 1
      visit namespaces_path(ns_page: 1)

      expect(page).to have_css(".namespaces-panel .pagination li.active:nth-child(2)")
    end

    scenario "URL is updated when page is changed", js: true do
      create_list(:namespace, 15, team: team, registry: registry)

      visit namespaces_path

      expect(page).to have_css(".namespaces-panel:last-of-type .pagination li:nth-child(3)")

      # page 2
      find(".namespaces-panel:last-of-type .pagination li:nth-child(3) a").click

      expect(page).to have_css(".namespaces-panel:last-of-type .pagination li.active:nth-child(3)")
      expect(page).to have_current_path(namespaces_path(ns_page: 2))

      # page 1
      find(".namespaces-panel:last-of-type .pagination li:nth-child(2) a").click

      expect(page).to have_css(".namespaces-panel:last-of-type .pagination li.active:nth-child(2)")
      expect(page).to have_current_path(namespaces_path(ns_page: 1))
    end
  end

  describe "#update" do
    scenario "user inputs a team does not exist", js: true do
      visit namespace_path(namespace.id)
      find(".toggle-link-edit-namespace").click

      fill_in "Team", with: "unknown"
      wait_for_ajax

      expect(page).to have_content("Selected team does not exist")
    end

    scenario "user removes the team", js: true do
      visit namespace_path(namespace.id)
      find(".toggle-link-edit-namespace").click

      fill_in "Team", with: ""

      expect(page).to have_content("Team can't be blank")
    end

    scenario "user updates namespace's team", js: true do
      new_team = create(:team, owners: [user])

      visit namespace_path(namespace.id)
      find(".toggle-link-edit-namespace").click

      fill_in "Team", with: new_team.name
      wait_for_ajax

      click_button "Save"

      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Namespace '#{namespace.name}' was updated successfully")
    end

    scenario "user updates namespace's description", js: true do
      visit namespace_path(namespace.id)
      find(".toggle-link-edit-namespace").click

      fill_in "Description", with: "Cool description"
      wait_for_ajax

      click_button "Save"

      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Cool description")
      expect(page).to have_content("Namespace '#{namespace.name}' was updated successfully")
    end
  end

  describe "#show" do
    it "shows the proper visual aid for each role", js: true do
      visit namespace_path(namespace.id)
      expect(page).to have_content("Push Pull Owner")

      login_as user2, scope: :user
      visit namespace_path(namespace.id)
      expect(page).to have_content("Push Pull Contr.")

      login_as user3, scope: :user
      visit namespace_path(namespace.id)
      expect(page).to have_content("Pull Viewer")
    end

    scenario "An user sees dropdown for 'Show webhooks'", js: true do
      visit namespace_path(namespace.id)

      expect(page).not_to have_content("Show webhooks")
      find("[data-toggle='dropdown']").click
      expect(page).to have_content("Show webhooks")
    end
  end
end
