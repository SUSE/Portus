# frozen_string_literal: true

require "rails_helper"

describe "Teams support", type: :system, js: true do
  let!(:registry) { create(:registry) }
  let!(:admin) { create(:admin) }
  let!(:another_user) { create(:user) }
  let!(:team) { create(:team, owners: [admin]) }
  let!(:team2) { create(:team, owners: [another_user]) }
  let!(:namespace) { create(:namespace, team: team, registry: registry) }

  before do
    login_as admin, scope: :user
  end

  describe "#index" do
    before do
      visit teams_path
      toggle_new_team_form
    end

    context "when admin" do
      context "invalid fields" do
        it "disables submit button" do
          expect(page).to have_button("Save", disabled: true)
        end

        it "shows name can't be blank message" do
          fill_in "Name", with: "name"
          clear_field("#team_name")

          expect(page).to have_content("Name can't be blank")
          expect(page).to have_button("Save", disabled: true)
        end

        it "shows name is reserved/taken message" do
          fill_in "Name", with: Team.last.name

          expect(page).to have_content("Name is reserved or has already been taken")
          expect(page).to have_button("Save", disabled: true)
        end
      end

      it "creates a team" do
        fill_in "Name", with: "valid-team"
        select admin.username, from: "team_owner_id"

        click_button "Save"

        expect(page).to have_content("Team 'valid-team' was created successfully")
        expect(page).to have_link("valid-team")
      end

      it "shows the teams links" do
        expect(page).to have_link(team.name)
        find(".team_#{team.id} a").click
        expect(page).to have_current_path(team_path(team))
      end

      it "shows other teams for admin" do
        expect(page).to have_content("Other teams")
        expect(page).to have_link(team2.name)
      end

      it "creates a team with a different owner" do
        fill_in "Name", with: "another"
        select another_user.username, from: "team_owner_id"

        click_button "Save"

        expect(page).to have_content("Team 'another' was created successfully")
        expect(page).to have_link("another")
      end
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
        toggle_new_team_form

        expect(page).not_to have_css("#team_owner_id")
      end

      it "creates a team" do
        toggle_new_team_form
        fill_in "Name", with: "valid-team2"

        click_button "Save"

        expect(page).to have_content("Team 'valid-team2' was created successfully")
        expect(page).to have_link("valid-team2")
      end

      context "permission disabled" do
        it "doesn't see link to create team" do
          APP_CONFIG["user_permission"]["create_team"]["enabled"] = false
          visit teams_path

          expect(page).not_to have_content("Create new team")
        end
      end
    end
  end

  describe "#update" do
    before do
      visit team_path(team)
      toggle_edit_team_form
    end

    it "updates a team name" do
      new_team_name = "New #{team.name}"
      fill_in "team[name]", with: new_team_name
      click_button "Save"

      expect(page).to have_content("Team '#{new_team_name}' was updated successfully")
      expect(find(".team-name").text).to eq(new_team_name)
    end

    context "invalid fields" do
      it "shows name can't be blank message" do
        clear_field("#team_name")

        expect(page).to have_content("Name can't be blank")
        expect(page).to have_button("Save", disabled: true)
      end

      it "shows name is reserved/taken message" do
        fill_in "Name", with: Team.last.name

        expect(page).to have_content("Name is reserved or has already been taken")
        expect(page).to have_button("Save", disabled: true)
      end
    end
  end

  context "#destroy" do
    let(:delete_migrate_btn) { "Migrate namespaces and delete team" }

    before do
      APP_CONFIG["delete"] = { "enabled" => true }
      visit team_path(team)
      toggle_team_delete_modal
    end

    it "deletes team with namespaces" do
      click_button "Delete team and its namespaces"

      expect(page).to have_content("Team '#{team.name}' was removed successfully")
    end

    it "deletes team without namespaces" do
      visit team_path(team2)
      toggle_team_delete_modal
      click_button "I understand, delete team"

      expect(page).to have_content("Team '#{team2.name}' was removed successfully")
    end

    it "deletes team migrating all its namespaces" do
      select_vue_multiselect(".team_select", team2.name)
      click_button delete_migrate_btn

      expect(page).to have_content("Team '#{team.name}' was removed successfully and its "\
        "namespaces were migrated to '#{team2.name}'")
      expect(page).to have_current_path(teams_path)

      visit team_path(team2)
      expect(page).to have_link(namespace.name)
    end

    it "cannot migrate namespaces to the same team" do
      select_vue_multiselect(".team_select", team.name)

      expect(page).to have_content("You cannot select the original team")
      expect(page).to have_button(delete_migrate_btn, disabled: true)
    end

    it "doesn't show delete options if delete is disabled" do
      APP_CONFIG["delete"] = { "enabled" => false }
      visit team_path(team)

      expect(page).not_to have_css(".toggle-delete-modal")
    end
  end

  describe "#show" do
    let!(:another) { create(:user) }
    let!(:another_admin) { create(:admin) }

    before do
      visit team_path(team)
    end

    it "creates a namespace from the team page" do
      toggle_new_namespace_form

      fill_in "Name", with: "new-namespace"
      click_button "Save"

      expect(page).to have_content("Namespace 'new-namespace' was created successfully")
      expect(page).to have_link("new-namespace")
    end

    context "deletion" do
      before do
        APP_CONFIG["user_permission"]["manage_team"]["enabled"] = false
      end

      it "hides team deletion option for owner if feature is not enabled" do
        tu = TeamUser.create!(team: team, user: another, role: TeamUser.roles["owner"])
        login_as tu.user, scope: :user
        visit team_path(team)

        expect(page).to_not have_css(".delete-team-user-btn")
      end

      it "shows team deletion option for admin even if feature is disabled" do
        visit team_path(team)

        expect(page).to have_css(".delete-team-user-btn")
      end
    end

    context "table sorting" do
      it "considers url parameters" do
        # sort asc & created_at
        visit team_path(team, ns_sort_asc: true, ns_sort_by: "created_at")
        expect(page).to have_css(".namespaces-panel th:nth-child(4) .fa-sort-amount-asc")

        # sort desc & created_at
        visit team_path(team, ns_sort_asc: false, ns_sort_by: "created_at")
        expect(page).to have_css(".namespaces-panel th:nth-child(4) .fa-sort-amount-desc")
      end

      it "updates url when sorted" do
        path = team_path(team, ns_sort_asc: true, ns_sort_by: "created_at")
        find(".namespaces-panel th:nth-child(4)").click

        expect(page).to have_css(".namespaces-panel th:nth-child(4) .fa-sort-amount-asc")
        expect(page).to have_current_path(path)

        # sort desc & created_at
        path = team_path(team, ns_sort_asc: false, ns_sort_by: "created_at")
        find(".namespaces-panel th:nth-child(4)").click

        expect(page).to have_css(".namespaces-panel th:nth-child(4) .fa-sort-amount-desc")
        expect(page).to have_current_path(path)
      end
    end

    context "table pagination" do
      before do
        create_list(:namespace, 15, team: team, registry: registry)
      end

      it "considers url parameters" do
        # page 2
        visit team_path(team, ns_page: 2)
        expect(page).to have_css(".namespaces-panel .pagination li.active:nth-child(3)")

        # page 1
        visit team_path(team, ns_page: 1)
        expect(page).to have_css(".namespaces-panel .pagination li.active:nth-child(2)")
      end

      it "updates url when paginated" do
        visit team_path(team)

        within ".namespaces-panel:last-of-type" do
          # page 2
          find(".pagination li:nth-child(3) a").click

          expect(page).to have_css(".pagination li.active:nth-child(3)")
          expect(page).to have_current_path(team_path(team, ns_page: 2))

          # page 1
          find(".pagination li:nth-child(2) a").click

          expect(page).to have_css(".pagination li.active:nth-child(2)")
          expect(page).to have_current_path(team_path(team, ns_page: 1))
        end
      end
    end

    context "members" do
      it "adds an user as a team member" do
        toggle_new_member_form

        select "Contributor", from: "Role"
        select_vue_multiselect(".team_user_user", another.username)

        expect(page).to have_button("Add")
        click_button "Add"

        expect(page).to have_content("'#{another.username}' was successfully added to the team")
        expect(page).to have_css(".team_member_#{TeamUser.last.id} .role", text: "Contributor")
      end

      it "adds admin user only as a team owner" do
        toggle_new_member_form

        select "Contributor", from: "Role"
        select_vue_multiselect(".team_user_user", another_admin.username)

        expect(page).to have_button("Add")
        click_button "Add"

        expect(page).to have_content(
          "User '#{another_admin.display_username}' was added to the team " \
          "(promoted to owner because it's a Portus admin)"
        )
        expect(page).to have_css(".team_member_#{TeamUser.last.id} .role", text: "Owner")
      end

      it "doesn't allow inexistent user to be added as a team member" do
        toggle_new_member_form

        select "Contributor", from: "Role"
        fill_vue_multiselect(".team_user_user", "grumpy")

        expect(page).to have_content("Oops! No username found.")
        expect(page).to have_button("Add", disabled: true)
      end

      it "updates a team member role" do
        tu = TeamUser.create!(team: team, user: another, role: TeamUser.roles["viewer"])
        visit team_path(team)

        within ".team_member_#{tu.id}" do
          find(".edit-member-btn").click
          select "Contributor", from: "select_role_#{tu.id}"
          find(".btn-primary").click
        end

        expect(page).to have_content("User '#{another.username}' was successfully updated")
        expect(page).to have_css(".team_member_#{tu.id} .role", text: "Contributor")
      end

      it "removes a team member from a team" do
        tu = TeamUser.create!(team: team, user: another, role: TeamUser.roles["viewer"])
        visit team_path(team)

        click_confirm_popover(".team_member_#{tu.id} .delete-team-user-btn")

        expect(page).to have_content(
          "User '#{another.username}' was successfully removed from the team"
        )
      end

      it "doesn't allow the removal of unique team member" do
        click_confirm_popover(".delete-team-user-btn")

        expect(page).to have_content("Cannot remove the only owner of the team")
      end
    end
  end
end
