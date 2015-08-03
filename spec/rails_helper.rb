
ENV["RAILS_ENV"] ||= "test"

require "spec_helper"
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "devise"
require "ffaker"
require "factory_girl_rails"
require "pundit/rspec"

# Raise exception for pending migrations after reading the schema.
ActiveRecord::Migration.maintain_test_schema!

# All the configuration that is specific for a gem (or set of related gems) has
# been pushed into individual files inside the `spec/support` directory.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # If we want Capybara + DatabaseCleaner + Poltergeist to work correctly, we
  # have to just set this to false.
  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!
  config.include FactoryGirl::Syntax::Methods
  config.infer_base_class_for_anonymous_controllers = true
end
