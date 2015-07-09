
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'simplecov'
require 'webmock/rspec'
require 'vcr'

SimpleCov.minimum_coverage 100
SimpleCov.start 'rails'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true

  # So code coverage reports can be submitted to codeclimate.com
  c.ignore_hosts 'codeclimate.com'
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Some tests use Timecop, just make sure that everything is as expected
  # after returning from it.
  config.before :each do
    Timecop.return
  end

  config.order = :random
end
