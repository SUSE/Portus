require 'rails_helper'

feature 'Signup feature' do

  before do
    create(:user, admin: true)
    visit new_user_registration_url
  end

  let(:user) { build(:user) }

  scenario 'As a guest I am able to signup from login page' do
    visit new_user_session_url
    click_link('Sign Up')
    expect(page).to have_field('user_email')
  end

  scenario 'If the admin user has been created, I am not able to create it' do
    User.delete_all
    visit new_user_registration_url
    expect(page).to have_content('Create admin')
  end

  scenario 'As a guest I am able to signup' do
    expect(page).to_not have_content('Create admin')
    fill_in 'user_username', with: user.username
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    fill_in 'user_password_confirmation', with: user.password
    click_button('Sign Up')
    expect(page).to have_content('Your stats')
    expect(current_url).to eq dashboard_url
  end

  scenario 'As a guest I can see error prohibiting my registration to be completed' do
    fill_in 'user_username', with: user.username
    fill_in 'user_email', with: 'gibberish'
    fill_in 'user_password', with: user.password
    fill_in 'user_password_confirmation', with: user.password
    click_button('Sign Up')
    expect(page).to have_content('1 error prohibited this user from being saved: Email is invalid')
  end

end
