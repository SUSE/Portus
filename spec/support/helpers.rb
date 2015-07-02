
# A simple module containing some helper methods for acceptance tests.
module Helpers
  # Login the given user and visit the root url.
  def login(user)
    login_as user, scope: :user
    visit root_url
  end
end

RSpec.configure { |config| config.include Helpers, type: :feature }
