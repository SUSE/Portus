require 'rails_helper'

feature 'Teams support', focus: true do
  let!(:registry) { create(:registry) }
  let!(:user) { create(:user, admin: true) }
  let!(:team) { create(:team, owners: [user]) }

  before do
    login_as user, scope: :user
  end

  scenario 'A namespace can be created from the team page', js: true do
    visit team_path(team)

    # The form appears after clicking the "Add namespace" link.
    expect(find('#add_namespace_form', visible: false)).to_not be_visible
    find('#add_namespace_btn').click
    expect(find('#add_namespace_form')).to be_visible
    sleep 1
    id = page.evaluate_script('document.activeElement.id')
    expect(id).to eq 'namespace_namespace'

    # Fill the form and wait for the AJAX response.
    fill_in 'Namespace', with: 'new-namespace'
    click_button 'Add'
    wait_for_ajax

    # See the response.
    namespace = Namespace.find_by(name: 'new-namespace')
    expect(page).to have_css("#namespace_#{namespace.id}")
    sleep 2
    expect(find('#add_namespace_form', visible: false)).to_not be_visible
  end
end
