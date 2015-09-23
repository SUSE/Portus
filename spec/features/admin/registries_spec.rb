require "rails_helper"

feature "Admin - Registries panel" do
  let!(:admin) { create(:admin) }

  before do
    login_as admin
  end

  describe "toggling `use_ssl` from a registry" do
    let!(:registry) { create(:registry) }

    before :each do
      visit admin_registries_path
    end

    it "toggles the `use_ssl` properly", js: true do
      expect(page).to have_css("#registry_#{registry.id} .fa-toggle-off")
      expect(page).to_not have_css("#registry_#{registry.id} .fa-toggle-on")
      find("#registry_#{registry.id} td a i").click

      wait_for_ajax
      wait_for_effect_on("#alert")

      expect(page).to_not have_css("#registry_#{registry.id} .fa-toggle-off")
      expect(page).to have_css("#registry_#{registry.id} .fa-toggle-on")
    end
  end
end
