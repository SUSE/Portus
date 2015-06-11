require 'rails_helper'

feature 'Logout feature' do

  let!(:user) { create(:user) }

  before do
    # TODO: DRY it out - share with other scenarious outside this feature
    visit root_url
    fill_in 'user_username', with: user.username
    fill_in 'user_password', with: user.password
    click_button 'Login'
  end

  scenario 'Redirects to login screen' do
    click_link('logout')
    expect(current_url).to eq new_user_session_url
    expect(page).to_not have_content('Signed out')
  end

  scenario 'After login guest redirects to login page when he attempts to access dashboard again' do
    click_link('logout')
    visit root_url
    expect(current_url).to eq new_user_session_url
  end

end
