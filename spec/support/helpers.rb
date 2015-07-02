
# A simple module containing some helper methods for acceptance tests.
module Helpers
  # Login the given user and visit the root url.
  def login(user)
    login_as user, scope: :user
    visit root_url
  end

  # Returns a String containing the id of the currently active element.
  def focused_element_id
    page.evaluate_script('document.activeElement.id')
  end

  # Returns a boolean regarding whether the given selector matches an element
  # that is currently disabled.
  def disabled?(selector)
    page.evaluate_script("$('#{selector}').attr('disabled')") == 'disabled'
  end
end

RSpec.configure { |config| config.include Helpers, type: :feature }
