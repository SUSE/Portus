# frozen_string_literal: true

# Setup devise for tests.
RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :helper
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Needed for methods such as `login_as`.
  config.include Warden::Test::Helpers
  config.before(:suite) { Warden.test_mode! }
end
