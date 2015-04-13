require 'rails_helper'

feature 'Basic feature' do

  scenario 'Page should be properly rendered' do
    visit '/'
    expect(page).to have_content('Servus!')
  end

end
