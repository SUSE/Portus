
# Setup devise for tests.
RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :helper
  config.include Devise::TestHelpers, type: :view

  # Needed for methods such as `login_as`.
  config.include Warden::Test::Helpers
  config.before(:suite) { Warden.test_mode! }
end
