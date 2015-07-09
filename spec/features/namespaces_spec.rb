require 'rails_helper'

feature 'Namespaces support' do
  let!(:registry) { create(:registry) }
  let!(:user) { create(:admin) }
  let!(:team) { create(:team, owners: [user]) }
  let!(:namespace) { create(:namespace, team: team, registry: registry) }

  before do
    login_as user, scope: :user
  end

  describe 'Namespaces#index' do
    scenario 'An user cannot create an empty namespace', js: true do
      namespaces_count = Namespace.count

      visit namespaces_path
      find('#add_namespace_btn').click
      wait_for_effect_on('#new-namespace-form')

      click_button 'Create'
      wait_for_ajax
      wait_for_effect_on('#new-namespace-form')
      expect(Namespace.count).to eql namespaces_count
      expect(current_path).to eql namespaces_path
    end

    scenario 'An user cannot create a namespace that already exists', js: true do
      namespaces_count = Namespace.count

      visit namespaces_path
      find('#add_namespace_btn').click
      fill_in 'Namespace', with: Namespace.first.name
      fill_in 'Team', with: Team.first.name
      wait_for_effect_on('#new-namespace-form')

      click_button 'Create'
      wait_for_ajax
      wait_for_effect_on('#alert')
      expect(Namespace.count).to eql namespaces_count
      expect(current_path).to eql namespaces_path
      expect(page).to have_content('Name has already been taken')
      expect(page).to have_css('#alert .alert.alert-dismissible.alert-info')
    end

    scenario 'A namespace can be created from the index page', js: true do
      namespaces_count = Namespace.count

      visit namespaces_path
      find('#add_namespace_btn').click
      fill_in 'Namespace', with: 'valid-namespace'
      fill_in 'Team', with: namespace.team.name
      wait_for_effect_on('#new-namespace-form')

      click_button 'Create'
      wait_for_ajax
      wait_for_effect_on('#new-namespace-form')

      expect(Namespace.count).to eql namespaces_count + 1
      expect(current_path).to eql namespaces_path
      expect(page).to have_content('valid-namespace')

      # Check that it created a link to it and that it's accessible.
      click_link 'valid-namespace'
      namespace = Namespace.find_by(name: 'valid-namespace')
      expect(current_path).to eq namespace_path(namespace)
    end

    scenario 'The "Create new namespace" link has a toggle effect', js: true do
      visit namespaces_path
      expect(page).to have_css('#add_namespace_btn i.fa-plus-circle')
      expect(page).to_not have_css('#add_namespace_btn i.fa-minus-circle')

      find('#add_namespace_btn').click
      wait_for_effect_on('#new-namespace-form')

      expect(page).to_not have_css('#add_namespace_btn i.fa-plus-circle')
      expect(page).to have_css('#add_namespace_btn i.fa-minus-circle')

      find('#add_namespace_btn').click
      wait_for_effect_on('#new-namespace-form')

      expect(page).to have_css('#add_namespace_btn i.fa-plus-circle')
      expect(page).to_not have_css('#add_namespace_btn i.fa-minus-circle')
    end

    scenario 'The namespace can be toggled public/private', js: true do
      visit namespaces_path
      id = namespace.id

      expect(namespace.public?).to be false
      expect(page).to have_css("#namespace_#{id} .fa-toggle-off")

      find("#namespace_#{id} .btn").click
      wait_for_ajax

      expect(page).to have_css("#namespace_#{id} .fa-toggle-on")
      namespace = Namespace.find(id)
      expect(namespace.public?).to be true
    end
  end
end
