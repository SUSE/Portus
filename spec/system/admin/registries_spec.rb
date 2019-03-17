# frozen_string_literal: true

require "rails_helper"

describe "Admin - Registries panel" do
  let!(:admin) { create(:admin) }

  before do
    login_as admin
  end

  describe "#force_registry_config!" do
    it "redirects to new_admin_registry_path if no registry has been configured" do
      visit authenticated_root_path
      expect(page).to have_current_path(new_admin_registry_path)
    end

    it "is not redirected if there is a registry in place" do
      allow_any_instance_of(Registry).to receive(:reachable?).and_return("")

      create(:registry)
      visit admin_registries_path

      expect(page).to have_current_path(admin_registries_path)
    end
  end

  describe "#create", js: true do
    it "shows an error if name is blank" do
      visit new_admin_registry_path

      fill_in "registry_name", with: "registry"
      clear_field("#registry_name")

      expect(page).to have_content("Name can't be blank")
      expect(page).to have_button("Save", disabled: true)
    end

    it "shows an error if hostname is blank" do
      visit new_admin_registry_path

      fill_in "registry_hostname", with: "registry"
      clear_field("#registry_hostname")

      expect(page).to have_content("Hostname can't be blank")
      expect(page).to have_button("Save", disabled: true)
    end

    it "shows an error if hostname is not reachable" do
      allow_any_instance_of(Registry).to receive(:reachable?).and_return("connection refused")

      visit new_admin_registry_path

      expect(page).not_to have_content("Skip remote checks")

      fill_in "registry_name", with: "registry"
      fill_in "registry_hostname", with: "url_not_known:1234"

      expect(page).to have_content("Skip remote checks")
      expect(page).to have_content("connection refused")
      expect(page).to have_button("Save", disabled: true)
    end

    it "shows an error (hostname), but you can force it afterwards" do
      allow_any_instance_of(Registry).to receive(:reachable?).and_return("Error")

      visit new_admin_registry_path

      fill_in "registry_name", with: "registry"
      # for each field we do an ajax request to validate
      # the sleep below is to delay the hostname change
      # and guarantee the ajax responses order
      # and avoid flaky and unrealistic state
      sleep 1
      fill_in "registry_hostname", with: "url_not_known:1234"

      expect(page).to have_content("Skip remote checks")
      expect(page).to have_css("#force")

      # Use the force, Luke.

      check "force"
      expect(page).to have_button("Save")

      click_button "Save"

      expect(page).to have_current_path(admin_registries_path)
      expect(page).to have_content("Registry was successfully created.")
      expect(Registry).to be_any
    end

    it "shows advanced options when clicking on Show Advanced", js: true do
      visit new_admin_registry_path

      expect(page).not_to have_css("#advanced.collapse.in")

      click_button "Show Advanced"

      expect(page).to have_content("External Registry Name")
      expect(page).to have_css("#advanced.collapse.in")
    end

    it "hides advanced options when clicking on Hide Advanced", js: true do
      visit new_admin_registry_path

      click_button "Show Advanced"

      expect(page).to have_content("External Registry Name")
      expect(page).to have_css("#advanced.collapse.in")

      click_button "Hide Advanced"

      expect(page).not_to have_css("#advanced.collapse.in")
      expect(page).not_to have_content("External Registry Name")
    end
  end

  describe "Save", js: true do
    let!(:registry) { create(:registry) }

    before do
      visit edit_admin_registry_path(registry.id)
    end

    it "does not show the hostname if there are repositories" do
      expect(page).to have_css("#registry_hostname")

      create(:repository)
      visit edit_admin_registry_path(registry.id)

      expect(page).not_to have_css("#registry_hostname")
    end

    it "shows an error if hostname is not reachable" do
      allow_any_instance_of(Registry).to receive(:reachable?).and_return("connection refused")

      fill_in "registry_name", with: "registry"
      fill_in "registry_hostname", with: "url_not_known:1234"

      expect(page).to have_content("Skip remote checks")
      expect(page).to have_content("connection refused")
      expect(page).to have_button("Save", disabled: true)
    end

    it "shows advanced options when clicking on Show Advanced" do
      expect(page).not_to have_css("#advanced")

      click_button "Show Advanced"

      expect(page).to have_content("External Registry Name")
      expect(page).to have_css("#advanced.collapse.in")
    end

    it "hides advanced options when clicking on Hide Advanced" do
      click_button "Show Advanced"

      expect(page).to have_content("External Registry Name")
      expect(page).to have_css("#advanced.collapse.in")

      click_button "Hide Advanced"

      expect(page).not_to have_css("#advanced.collapse.in")
      expect(page).not_to have_content("External Registry Name")
    end
  end
end
