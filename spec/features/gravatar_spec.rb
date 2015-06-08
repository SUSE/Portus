require 'rails_helper'

feature 'Gravatar support' do

  let!(:user) { create(:user) }

  before do
    # TODO: DRY it out - share with other scenarious outside this feature
    visit root_url
    fill_in 'user_username', with: user.username
    fill_in 'user_password', with: user.password
    click_button 'Login'
  end

  scenario 'If gravatar support is on, there should be an image' do
    APP_CONFIG['gravatar'] = true
    visit root_url
    expect(page).to have_selector('.user-header img')
  end

  scenario 'If gravatar suppor is disabled, there should be an icon' do
    APP_CONFIG['gravatar'] = false
    visit root_url
    expect(page).to have_selector('.user-header .fa-user')
  end

end
