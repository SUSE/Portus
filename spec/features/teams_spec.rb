# frozen_string_literal: true

require "rails_helper"

describe "Teams support" do
  let!(:registry) { create(:registry) }
  let!(:admin) { create(:admin) }
  let!(:another_user) { create(:user) }
  let!(:team) { create(:team, owners: [admin]) }
  let!(:team2) { create(:team, owners: [another_user]) }

  before do
    login_as admin, scope: :user
  end

  describe "teams#index", js: true do
    before do
      visit teams_path
    end

    it "A user cannot create an empty team" do
      find(".toggle-link-new-team").click
      wait_for_effect_on("#new-team-form")

      fill_in "Name", with: Team.first.name
      fill_in "Name", with: ""

      expect(page).to have_content("Name can't be blank")
      expect(page).to have_button("Add", disabled: true)
    end

    it "A team cannot be created if the name has already been picked" do
      find(".toggle-link-new-team").click
      wait_for_effect_on("#new-team-form")

      fill_in "Name", with: Team.last.name
      wait_for_ajax

      expect(page).to have_content("Name is reserved or has already been taken")
      expect(page).to have_button("Add", disabled: true)
    end

    it "A team can be created from the index page" do
      teams_count = Team.count

      find(".toggle-link-new-team").click
      wait_for_effect_on("#new-team-form")

      fill_in "Name", with: "valid-team"
      select admin.username, from: "team_owner_id"
      wait_for_ajax

      click_button "Add"
      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Team 'valid-team' was created successfully")
      expect(page).to have_link("valid-team")
      expect(page).to have_current_path(teams_path)
      expect(Team.count).to eql(teams_count + 1)
    end

    it 'The "Create new team" link has a toggle effect' do
      expect(page).to have_css(".toggle-link-new-team i.fa-plus-circle")
      expect(page).not_to have_css(".toggle-link-new-team i.fa-minus-circle")

      find(".toggle-link-new-team").click
      wait_for_effect_on("#new-team-form")

      expect(page).not_to have_css(".toggle-link-new-team i.fa-plus-circle")
      expect(page).to have_css(".toggle-link-new-team i.fa-minus-circle")

      find(".toggle-link-new-team").click
      wait_for_effect_on("#new-team-form")

      expect(page).to have_css(".toggle-link-new-team i.fa-plus-circle")
      expect(page).not_to have_css(".toggle-link-new-team i.fa-minus-circle")
    end

    it "The name of each team is a link" do
      expect(page).to have_link(team.name)
      find(".team_#{team.id} a").click
      expect(page).to have_current_path(team_path(team))
    end

    it "Disabled users do not count" do
      user = create(:user)
      team.viewers = [user]
      team.save!
      visit teams_path

      expect(page).to have_css("td:nth-child(4)", text: "2")

      user.enabled = false
      user.save!
      visit teams_path

      expect(page).to have_css("td:nth-child(4)", text: "1")
      expect(page).not_to have_css("td:nth-child(4)", text: "2")
    end

    it "shows other teams" do
      expect(page).to have_content("Other teams")
    end

    it "shows owner select" do
      find(".toggle-link-new-team").click
      wait_for_effect_on("#new-team-form")

      expect(page).to have_css("#team_name")
      expect(page).to have_css("#team_owner_id")
    end

    it "creates a team with a different owner" do
      find(".toggle-link-new-team").click
      wait_for_effect_on("#new-team-form")

      fill_in "Name", with: "another"
      select another_user.username, from: "team_owner_id"

      click_button "Add"
      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Team 'another' was created successfully")
      expect(page).to have_link("another")
    end

    context "when not admin" do
      before do
        login_as another_user, scope: :user
        visit teams_path
      end

      it "doesn't show other teams" do
        expect(page).not_to have_content("Other teams")
      end

      it "doesn't show owner select" do
        find(".toggle-link-new-team").click
        wait_for_effect_on("#new-team-form")

        expect(page).to have_css("#team_name")
        expect(page).not_to have_css("#team_owner_id")
      end
    end
  end

  describe "teams#update" do
    it "Team name can be updated", js: true do
      visit team_path(team)

      find(".toggle-link-edit-team").click

      new_team_name = "New #{team.name}"
      fill_in "team[name]", with: new_team_name
      click_button "Save"
      wait_for_ajax

      expect(page).to have_content("Team '#{new_team_name}' was updated successfully")
      expect(find(".team-name").text).to eq(new_team_name)
    end
  end

  describe "teams#show" do
    let!(:another) { create(:user) }
    let!(:another_admin) { create(:admin) }

    before do
      visit team_path(team)
    end

    # TODO: move this test to a component level one instead of feature once
    # form component is migrated to a vue file
    it "hides team field if team is defined", js: true do
      find(".toggle-link-new-namespace").click

      expect(page).to have_css("#namespace_name")
      expect(page).not_to have_css(".namespace_team")
    end

    it "A namespace can be created from the team page", js: true do
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

    it "Namespace table sorting is reachable through url", js: true do
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

    it "URL is updated when namespaces column is sorted", js: true do
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

    it "Namespace table pagination is reachable through url", js: true do
      create_list(:namespace, 15, team: team, registry: registry)

      # page 2
      visit team_path(team, ns_page: 2)

      expect(page).to have_css(".namespaces-panel .pagination li.active:nth-child(3)")

      # page 1
      visit team_path(team, ns_page: 1)

      expect(page).to have_css(".namespaces-panel .pagination li.active:nth-child(2)")
    end

    it "URL is updated when page is changed", js: true do
      create_list(:namespace, 15, team: team, registry: registry)

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

    it "An user can be added as a team member", js: true do
      find(".toggle-link-new-member").click

      select "Contributor", from: "Role"
      select_vue_multiselect(".team_user_user", another.username)

      expect(page).to have_button("Add")
      click_button "Add"

      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("'#{another.username}' was successfully added to the team")
      expect(page).to have_css(".team_member_#{TeamUser.last.id} .role", text: "Contributor")
    end

    it "An admin can only be added as a team owner", js: true do
      find(".toggle-link-new-member").click

      select "Contributor", from: "Role"
      select_vue_multiselect(".team_user_user", another_admin.username)

      expect(page).to have_button("Add")
      click_button "Add"

      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content(
        "User '#{another_admin.display_username}' was added to the team (promoted to
        owner because it's a Portus admin)"
      )
      expect(page).to have_css(".team_member_#{TeamUser.last.id} .role", text: "Owner")
    end

    it "New team members have to exist on the system", js: true do
      find(".toggle-link-new-member").click

      select "Contributor", from: "Role"
      fill_vue_multiselect(".team_user_user", "grumpy")

      expect(page).to have_content("Oops! No username found.")
      expect(page).to have_button("Add", disabled: true)
    end

    it "A team member can have his role updated", js: true do
      tu = TeamUser.create!(team: team, user: another, role: TeamUser.roles["viewer"])
      visit team_path(team)

      find(".team_member_#{tu.id} .edit-member-btn").click
      # expect(page).to have_css("#select_role_#{tu.id}")
      select "Contributor", from: "select_role_#{tu.id}"
      find(".team_member_#{tu.id} .btn-primary").click

      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("User '#{another.username}' was
       successfully updated")
      expect(page).to have_css(".team_member_#{tu.id} .role", text: "Contributor")
    end

    it "A team member can be kicked out from a team", js: true do
      tu = TeamUser.create!(team: team, user: another, role: TeamUser.roles["viewer"])
      visit team_path(team)

      find(".team_member_#{tu.id} .delete-team-user-btn").click
      find(".popover-content .yes").click

      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("User '#{another.username}' was
       successfully removed from the team")
    end

    it "The only member of a team cannot be removed", js: true do
      find(".delete-team-user-btn").click
      find(".popover-content .yes").click

      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Cannot remove the only owner of the team")
    end

    it "A team owner (not admin) cannot manage team if feature not enabled", js: true do
      APP_CONFIG["user_permission"]["manage_team"]["enabled"] = false

      tu = TeamUser.create!(team: team, user: another, role: TeamUser.roles["owner"])
      login_as tu.user, scope: :user
      visit team_path(team)

      expect(page).to_not have_css(".delete-team-user-btn")
    end
  end
end
