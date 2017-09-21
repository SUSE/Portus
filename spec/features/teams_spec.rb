require "rails_helper"

feature "Teams support" do
  let!(:registry) { create(:registry) }
  let!(:user) { create(:admin) }
  let!(:team) { create(:team, owners: [user]) }

  before do
    login_as user, scope: :user
  end

  describe "teams#index" do
    scenario "A user cannot create an empty team", js: true do
      teams_count = Team.count

      visit teams_path
      find("#add_team_btn").click

      click_button "Add"
      wait_for_ajax

      expect(Team.count).to eql teams_count
      expect(page).to have_current_path(teams_path)
    end

    scenario "A team cannot be created if the name has already been picked", js: true do
      teams_count = Team.count

      visit teams_path
      find("#add_team_btn").click
      fill_in "Name", with: Team.first.name

      click_button "Add"
      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Name has already been taken")
      expect(page).to have_current_path(teams_path)
      expect(Team.count).to eql teams_count
    end

    scenario "A team can be created from the index page", js: true do
      teams_count = Team.count

      visit teams_path
      find("#add_team_btn").click
      fill_in "Name", with: "valid-team"

      click_button "Add"
      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Team 'valid-team' was created successfully")
      expect(page).to have_link("valid-team")
      expect(page).to have_current_path(teams_path)
      expect(Team.count).to eql(teams_count + 1)
    end

    scenario 'The "Create new team" link has a toggle effect', js: true do
      visit teams_path
      expect(page).to have_css("#add_team_btn i.fa-plus-circle")
      expect(page).to_not have_css("#add_team_btn i.fa-minus-circle")

      find("#add_team_btn").click
      wait_for_effect_on("#add_team_form")

      expect(page).to_not have_css("#add_team_btn i.fa-plus-circle")
      expect(page).to have_css("#add_team_btn i.fa-minus-circle")

      find("#add_team_btn").click
      wait_for_effect_on("#add_team_form")

      expect(page).to have_css("#add_team_btn i.fa-plus-circle")
      expect(page).to_not have_css("#add_team_btn i.fa-minus-circle")
    end

    scenario "The name of each team is a link" do
      visit teams_path
      expect(page).to have_content(team.name)
      find("#teams a").click
      expect(page).to have_current_path(team_path(team))
    end

    scenario "Disabled users do not count" do
      user = create(:user)
      team.viewers = [user]
      team.save!
      visit teams_path

      expect(page).to have_css("td:nth-child(4)", text: "2")

      user.enabled = false
      user.save!
      visit teams_path

      expect(page).to have_css("td:nth-child(4)", text: "1")
      expect(page).to_not have_css("td:nth-child(4)", text: "2")
    end
  end

  describe "teams#update" do
    scenario "Team name can be updated", js: true do
      visit team_path(team)

      click_button "Edit team"
      expect(page).to have_css("form.edit_team")

      new_team_name = "New #{team.name}"
      fill_in "team[name]", with: new_team_name
      click_button "Save"
      wait_for_ajax

      expect(page).to have_content("Team '#{new_team_name}' was updated successfully")
      expect(page).to have_css("#team_user_team[value='#{new_team_name}']", visible: false)
      expect(page).to have_css("#namespace_team[value='#{new_team_name}']", visible: false)
      expect(find(".team_name").text).to eq(new_team_name)
    end
  end

  describe "teams#show" do
    let!(:another) { create(:user) }
    let!(:another_admin) { create(:admin) }

    before :each do
      visit team_path(team)
    end

    scenario "A namespace can be created from the team page", js: true do
      namespaces_count = Namespace.count

      # The form appears after clicking the "Add namespace" link.
      expect(page).to have_css("#new-namespace-form", visible: false)

      find(".toggle-link-new-namespace").click
      wait_for_effect_on("#new-namespace-form")

      expect(page).to have_css("#new-namespace-form")

      # Fill the form and wait for the AJAX response.
      fill_in "Name", with: "new-namespace"
      click_button "Create"

      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Namespace 'new-namespace' was created successfully")

      expect(Namespace.count).to eql namespaces_count + 1
      expect(page).to have_link("new-namespace")
      find(:link, "new-namespace").trigger(:click)

      namespace = Namespace.find_by(name: "new-namespace")
      expect(page).to have_current_path(namespace_path(namespace))
    end

    scenario "Namespace table sorting is reachable through url", js: true do
      # sort asc
      visit team_path(team, ns_sort_asc: true)

      expect(page).to have_css(".namespaces-panel .fa-sort-amount-asc")

      # sort desc
      visit team_path(team, ns_sort_asc: false)

      expect(page).to have_css(".namespaces-panel .fa-sort-amount-desc")

      # sort asc & created_at
      visit team_path(team, ns_sort_asc: true, ns_sort_by: "created_at")

      expect(page).to have_css(".namespaces-panel th:nth-child(4) .fa-sort-amount-asc")

      # sort desc & created_at
      visit team_path(team, ns_sort_asc: false, ns_sort_by: "created_at")

      expect(page).to have_css(".namespaces-panel th:nth-child(4) .fa-sort-amount-desc")
    end

    scenario "URL is updated when namespaces column is sorted", js: true do
      # sort asc & created_at
      find(".namespaces-panel th:nth-child(4)").click

      expect(page).to have_css(".namespaces-panel  th:nth-child(4) .fa-sort-amount-asc")
      path = team_path(team, ns_sort_asc: true, ns_sort_by: "created_at")
      expect(page).to have_current_path(path)

      # sort desc & created_at
      find(".namespaces-panel th:nth-child(4)").click

      expect(page).to have_css(".namespaces-panel th:nth-child(4) .fa-sort-amount-desc")
      path = team_path(team, ns_sort_asc: false, ns_sort_by: "created_at")
      expect(page).to have_current_path(path)
    end

    scenario "Namespace table pagination is reachable through url", js: true do
      create_list(:namespace, 5, team: team, registry: registry)

      # page 2
      visit team_path(team, ns_page: 2)

      expect(page).to have_css(".namespaces-panel .pagination li.active:nth-child(3)")

      # page 1
      visit team_path(team, ns_page: 1)

      expect(page).to have_css(".namespaces-panel .pagination li.active:nth-child(2)")
    end

    scenario "URL is updated when page is changed", js: true do
      create_list(:namespace, 5, team: team, registry: registry)

      visit team_path(team)

      expect(page).to have_css(".namespaces-panel:last-of-type .pagination li:nth-child(3)")

      # page 2
      find(".namespaces-panel:last-of-type .pagination li:nth-child(3) a").click

      expect(page).to have_css(".namespaces-panel:last-of-type .pagination li.active:nth-child(3)")
      expect(page).to have_current_path(team_path(team, ns_page: 2))

      # page 2
      find(".namespaces-panel:last-of-type .pagination li:nth-child(2) a").click

      expect(page).to have_css(".namespaces-panel:last-of-type .pagination li.active:nth-child(2)")
      expect(page).to have_current_path(team_path(team, ns_page: 1))
    end

    scenario "An user can be added as a team member", js: true do
      find("#add_team_user_btn").click
      find("#team_user_role").select "Contributor"
      find("#team_user_user").set another.username
      find("#add_team_user_form .btn").click

      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("User '#{another.username}' was added to the team")
      expect(page).to have_css(".team-users-wrapper tbody tr:last-child .role", text: "Contributor")
    end

    scenario "An admin can only be added as a team owner", js: true do
      find("#add_team_user_btn").click
      find("#team_user_role").select "Contributor"
      find("#team_user_user").set another_admin.username
      find("#add_team_user_form .btn").click

      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content(
        "User '#{another_admin.username}' was added to the team (promoted to
        owner because it is a Portus admin)."
      )
      expect(page).to have_css(".team-users-wrapper tbody tr:last-child .role", text: "Owner")
    end

    scenario "New team members have to exist on the system", js: true do
      find("#add_team_user_btn").click
      find("#team_user_role").select "Contributor"
      find("#team_user_user").set "grumpy"
      find("#add_team_user_form .btn").click

      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("User cannot be found")
    end

    scenario "A team member can be kicked out from a team", js: true do
      tu = TeamUser.create!(team: team, user: another, role: TeamUser.roles["viewer"])
      visit team_path(team)

      find("#team_user_#{tu.id} .delete-team-user-btn").click
      find(".popover-content .btn-primary").click

      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("User '#{another.username}' was removed from the team")
    end

    scenario "The only member of a team cannot be removed", js: true do
      find("#team_users .delete-team-user-btn").click
      find(".popover-content .btn-primary").click

      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Cannot remove the only owner of the team")
    end
  end
end
