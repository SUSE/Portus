# frozen_string_literal: true

require "capybara/rails"
require "capybara/rspec"
require "capybara/poltergeist"

WAIT_TIME = 3.minutes

Capybara.register_driver :poltergeist do |app|
  options = {
    timeout:           WAIT_TIME,
    js_errors:         true,
    phantomjs_options: [
      "--proxy-type=none"
    ]
  }
  # NOTE: uncomment the line below to get more info on the current run.
  # options[:debug] = true
  Capybara::Poltergeist::Driver.new(app, options)
end

Capybara.javascript_driver = :poltergeist

Capybara.configure do |config|
  config.javascript_driver = :poltergeist
  config.default_max_wait_time = WAIT_TIME
  config.match = :one
  config.exact_options = true
  config.ignore_hidden_elements = true
  config.visible_text_only = true
  config.default_selector = :css
end
