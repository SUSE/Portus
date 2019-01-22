# frozen_string_literal: true

require "rails_helper"

describe "Namespaces support", type: :system, js: true do
  let!(:registry) { create(:registry) }
  let!(:user) { create(:admin) }
  let!(:user2) { create(:user) }
  let!(:user3) { create(:user) }
  let!(:team) { create(:team, owners: [user], contributors: [user2], viewers: [user3]) }
  let!(:team2) { create(:team, owners: [user]) }
  let!(:namespace) { create(:namespace, team: team, registry: registry) }
  let!(:orphan_namespace) do
    create(:namespace, team: registry.global_namespace.team, registry: registry)
  end

  before do
    login_as user, scope: :user
  end

  describe "#index" do
    before do
      visit namespaces_path
      toggle_new_namespace_form
    end

    it "shows proper namespace and orphan one submit button" do
      expect(page).to have_link(orphan_namespace.name, count: 1)
      expect(page).to have_link(namespace.name, count: 1)
      expect(page).to have_content("Orphan namespaces (no team assigned)")
    end

    context "invalid fields" do
      it "disables submit button" do
        expect(page).to have_button("Save", disabled: true)
      end

      it "shows name can't be blank message" do
        fill_in "Name", with: "something"
        clear_field("#namespace_name")

        expect(page).to have_content("Name can't be blank")
        expect(page).to have_button("Save", disabled: true)
      end

      it "shows name invalid chars message" do
        fill_in "Name", with: "!@#!@#"

        expect(page).to have_content("Name can only contain lower case alphanumeric characters")
        expect(page).to have_button("Save", disabled: true)
      end

      it "shows namespace that already exists message" do
        fill_in "Name", with: Namespace.first.name

        expect(page).to have_content("Name has already been taken")
        expect(page).to have_button("Save", disabled: true)
      end

      it "shows team not found message" do
        fill_in "Name", with: Namespace.first.name
        fill_vue_multiselect(".namespace_team", Team.where(hidden: true).first.name)

        expect(page).to have_content("Oops! No team found.")
        expect(page).to have_button("Save", disabled: true)
      end
    end

    it "creates a namespace" do
      fill_in "Name", with: "valid-namespace"
      select_vue_multiselect(".namespace_team", namespace.team.name)
      click_button "Save"

      expect(page).to have_content("Namespace 'valid-namespace' was created successfully")
      expect(page).to have_link("valid-namespace")
    end

    it "updates namespace visibility" do
      within ".namespace_#{namespace.id}" do
        expect(namespace.visibility_private?).to be true
        expect(page).to have_css(".private-btn.btn-primary")

        find(".protected-btn").click
        expect(page).to have_css(".protected-btn.btn-primary")
        expect(namespace.reload.visibility_protected?).to be true

        find(".public-btn").click
        expect(page).to have_css(".public-btn.btn-primary")
        expect(namespace.reload.visibility_public?).to be true
      end
    end

    context "table sorting" do
      it "considers url parameters" do
        # sort asc & created_at
        visit namespaces_path(ns_sort_asc: true, ns_sort_by: "created_at")
        expect(page).to have_css("th:nth-child(4) .fa-sort-amount-asc")

        # sort desc & created_at
        visit namespaces_path(ns_sort_asc: false, ns_sort_by: "created_at")
        expect(page).to have_css("th:nth-child(4) .fa-sort-amount-desc")
      end

      it "updates url when sorted" do
        path = namespaces_path(ns_sort_asc: true, ns_sort_by: "created_at")
        find(".member-namespaces-panel th:nth-child(4)").click

        expect(page).to have_css(".member-namespaces-panel th:nth-child(4) .fa-sort-amount-asc")
        expect(page).to have_current_path(path)

        # sort desc & created_at
        path = namespaces_path(ns_sort_asc: false, ns_sort_by: "created_at")
        find(".member-namespaces-panel th:nth-child(4)").click

        expect(page).to have_css(".member-namespaces-panel th:nth-child(4) .fa-sort-amount-desc")
        expect(page).to have_current_path(path)
      end
    end

    context "table pagination" do
      before do
        create_list(:namespace, 15, team: team, registry: registry)
      end

      it "considers url parameters" do
        # page 2
        visit namespaces_path(ns_page: 2)
        expect(page).to have_css(".namespaces-panel .pagination li.active:nth-child(3)")

        # page 1
        visit namespaces_path(ns_page: 1)
        expect(page).to have_css(".namespaces-panel .pagination li.active:nth-child(2)")
      end

      it "updates url when paginated" do
        visit namespaces_path

        within ".member-namespaces-panel" do
          # page 2
          find(".pagination li:nth-child(3) a").click

          expect(page).to have_css(".pagination li.active:nth-child(3)")
          expect(page).to have_current_path(namespaces_path(ns_page: 2))

          # page 1
          find(".pagination li:nth-child(2) a").click

          expect(page).to have_css(".pagination li.active:nth-child(2)")
          expect(page).to have_current_path(namespaces_path(ns_page: 1))
        end
      end
    end
  end

  describe "#update" do
    before do
      visit namespace_path(namespace.id)
    end

    context "form" do
      before do
        toggle_edit_namespace_form
      end

      context "invalid fields" do
        it "shows team not found message" do
          fill_vue_multiselect(".namespace_team", Team.where(hidden: true).first.name)

          expect(page).to have_content("Oops! No team found.")
        end

        it "shows team can't be blank message" do
          deselect_vue_multiselect(".namespace_team", namespace.team.name)

          expect(page).to have_content("Team can't be blank")
          expect(page).to have_button("Save", disabled: true)
        end
      end

      it "updates namespace's team" do
        select_vue_multiselect(".namespace_team", team2.name)
        click_button "Save"

        expect(page).to have_content("Namespace '#{namespace.name}' was updated successfully")
      end

      it "user updates namespace's description" do
        fill_in "Description", with: "Cool description"
        click_button "Save"

        expect(page).to have_content("Cool description")
        expect(page).to have_content("Namespace '#{namespace.name}' was updated successfully")
      end
    end

    context "transfer" do
      let(:submit_btn) { "I understand, transfer this namespace" }
      before do
        toggle_namespace_transfer_modal
      end

      it "transfers namespace to a new team" do
        select_vue_multiselect(".namespace_team", team2.name)
        click_button submit_btn

        expect(page).to have_content("Namespace '#{namespace.name}' has been transferred "\
          "successfully")
      end

      it "doesn't show global team on modal if orphan" do
        visit namespace_path(orphan_namespace)
        toggle_namespace_transfer_modal

        expect(page).not_to have_content("namespace from the #{orphan_namespace.team.name} team")
      end

      it "cannot submit an empty team" do
        expect(page).to have_button(submit_btn, disabled: true)
      end

      it "cannot transfer to the same team" do
        select_vue_multiselect(".namespace_team", team.name)

        expect(page).to have_content("You cannot select the original team")
        expect(page).to have_button(submit_btn, disabled: true)
      end
    end
  end

  describe "#show" do
    it "shows the proper visual aid for each role" do
      visit namespace_path(namespace.id)
      expect(page).to have_content("Push")
      expect(page).to have_content("Pull")
      expect(page).to have_content("Owner")

      login_as user2, scope: :user
      visit namespace_path(namespace.id)
      expect(page).to have_content("Push")
      expect(page).to have_content("Pull")
      expect(page).to have_content("Contr.")

      login_as user3, scope: :user
      visit namespace_path(namespace.id)
      expect(page).not_to have_content("Push")
      expect(page).to have_content("Pull")
      expect(page).to have_content("Viewer")
    end

    context "when user_permission.push_images is restricted" do
      before do
        APP_CONFIG["user_permission"]["push_images"]["policy"] = "allow-personal"
      end

      it "shows the proper visual aid for each role" do
        login_as user
        visit namespace_path(namespace.id)
        expect(page).to have_content("Push")
        expect(page).to have_content("Pull")
        expect(page).to have_content("Owner")

        login_as user2, scope: :user
        visit namespace_path(namespace.id)
        expect(page).not_to have_content("Push")
        expect(page).to have_content("Pull")
        expect(page).to have_content("Contr.")

        login_as user3, scope: :user
        visit namespace_path(namespace.id)
        expect(page).not_to have_content("Push")
        expect(page).to have_content("Pull")
        expect(page).to have_content("Viewer")
      end
    end
  end

  describe "#destroy" do
    it "destroys the namespace" do
      APP_CONFIG["delete"] = { "enabled" => true }
      visit namespace_path(namespace)

      click_confirm_popover(".namespace-delete-btn")
      expect(page).to have_current_path(namespaces_path)
      expect(page).to have_content("Namespace removed with all its repositories")
      expect(page).not_to have_link(namespace.clean_name)
    end

    it "doesn't show delete option if feature is disabled" do
      APP_CONFIG["delete"] = { "enabled" => false }
      visit namespace_path(namespace)

      expect(page).not_to have_css(".namespace-delete-btn")
    end
  end
end
