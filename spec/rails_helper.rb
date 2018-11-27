# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
ENV["NODE_ENV"]  ||= "test"

require "spec_helper"
require File.expand_path("../config/environment", __dir__)
require "rspec/rails"
require "pundit/rspec"

Capybara.server = :puma, { Silent: true }

# Raise exception for pending migrations after reading the schema.
ActiveRecord::Migration.maintain_test_schema!

# All the configuration that is specific for a gem (or set of related gems) has
# been pushed into individual files inside the `spec/support` directory.
Dir[Rails.root.join("spec", "support", "**", "*.rb")].each { |f| require f }

# Keep the original value of the PORTUS_DB_ADAPTER env. variable.
CONFIGURED_DB_ADAPTER = ENV["PORTUS_DB_ADAPTER"]

require "shoulda/matchers"

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# To avoid problems, the LDAP authenticatable is enabled always. Since this
# means trouble for regular logins, we mock Portus::LDAP to implement a fake
# authenticate method. This method will be used by everyone. Tests that really
# want to interface with the real LDAP support, have to call the following in a
# before(:each) block:
#
#   allow_any_instance_of(Portus::LDAP).to receive(:authenticate!).and_call_original
#
Portus::LDAP::Authenticatable.class_eval do
  def fake_authenticate!
    # rubocop:disable Style/SignalException
    fail(:invalid_login)
    # rubocop:enable Style/SignalException
  end
end

RSpec.configure do |config|
  # Configure FactoryBot.
  config.include FactoryBot::Syntax::Methods

  # Infer the spec type from the location.
  config.infer_spec_type_from_file_location!
  config.infer_base_class_for_anonymous_controllers = true

  # By default, LDAP will be faked away.
  config.before do
    allow_any_instance_of(Portus::LDAP::Authenticatable).to(
      receive(:authenticate!)
        .and_return(:fake_authenticate!)
    )
  end

  ##
  # System tests

  config.include Devise::Test::IntegrationHelpers, type: :system

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end
end
