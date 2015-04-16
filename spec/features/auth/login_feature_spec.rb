require 'rails_helper'

feature 'Login feature' do

  let!(:user) { create(:user) }

  before do
    visit new_user_session_url
  end

  scenario 'Existing user is able using his login and password to login into Portus' do
    expect(page).to_not have_content('Invalid username or password')
    fill_in 'user_username', with: user.username
    fill_in 'user_password', with: user.password
    click_button 'Login'
    expect(page).to have_content('Servus!')
  end

  scenario 'Wrong password results in an error message' do
    fill_in 'user_username', with: 'foo'
    fill_in 'user_password', with: 'bar'
    click_button 'Login'
    expect(current_url).to eq new_user_session_url
    expect(page).to have_content('Invalid username or password')
  end

  scenario 'When guest is trying to access dashboard - he should be redirected to login page' do
    visit dashboard_url
    expect(current_url).to eq new_user_session_url
  end

end
