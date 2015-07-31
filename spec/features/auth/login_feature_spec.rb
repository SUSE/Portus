require 'rails_helper'

feature 'Login feature' do

  let!(:user) { create(:user) }

  before do
    visit new_user_session_url
  end

  scenario 'It does not show any flash when accessing for the first time' do
    visit root_url
    expect(page).to_not have_content('You need to sign in or sign up before continuing.')
  end

  scenario 'Existing user is able using his login and password to login into Portus' do
    expect(page).to_not have_content('Invalid username or password')

    # We don't use Capybara's `login_as` method on purpose, because we are
    # testing the UI for logging in.
    fill_in 'user_username', with: user.username
    fill_in 'user_password', with: user.password
    click_button 'Login'

    expect(page).to have_content('Activities')
    expect(page).to_not have_content('Signed in')
  end

  scenario 'Wrong password results in an error message' do
    fill_in 'user_username', with: 'foo'
    fill_in 'user_password', with: 'bar'
    click_button 'Login'
    expect(current_url).to eq new_user_session_url
    expect(page).to have_content('Invalid username or password')
  end

  scenario 'When guest is trying to access dashboard - he should be redirected to login page' do
    visit root_url
    expect(page).to have_content('Login')
    expect(current_url).to eq root_url
  end

  scenario 'A disabled user cannot login' do
    user.update_attributes(enabled: false)
    fill_in 'user_username', with: user.username
    fill_in 'user_password', with: user.password
    click_button 'Login'

    expect(page).to have_content(user.inactive_message)
    expect(page).to have_content('Login')
    expect(current_url).to eq new_user_session_url
  end
end
