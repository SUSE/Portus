require 'rails_helper'

feature 'Update password feature' do

  let!(:user) { create(:user) }

  before do
    visit new_user_session_url
    fill_in 'user_username', with: user.username
    fill_in 'user_password', with: user.password
    click_button 'Login'
    visit edit_user_registration_url
  end

  scenario 'On success, it does not log out the user' do
    fill_in 'user_current_password', with: user.password
    fill_in 'user_password', with: '12341234'
    fill_in 'user_password_confirmation', with: '12341234'

    # disabled: true; because this is handled by JS through the keyup function,
    # which won't be fired up by this test.
    click_button 'Change', disabled: true

    expect(current_url).to eq edit_user_registration_url
  end
end

