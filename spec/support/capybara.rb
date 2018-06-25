# frozen_string_literal: true

require "selenium-webdriver"
require "capybara/rails"
require "capybara/rspec"
require "capybara/poltergeist"

require_relative "containers"

WAIT_TIME = ENV["TRAVIS"] ? 30 : 10

# HACK: when running tests inside of a container we should use poltergeist
# This is unfortunately necessary due to an instability of capybara and chromedriver
# raising Net::ReadTimeout exception
JAVASCRIPT_DRIVER = Containers.dockerized? ? :poltergeist : :chrome

# Most of below was extracted from
# https://gitlab.com/gitlab-org/gitlab-ce/blob/master/spec/support/capybara.rb

# Define an error class for JS console messages
JSConsoleError = Class.new(StandardError)

# Filter out innocuous JS console messages
JS_CONSOLE_FILTER = Regexp.union(
  [
    "Download the Vue Devtools extension",
    "You are running Vue in development mode"
  ]
)

unless ENV["TRAVIS"]
  require "capybara-screenshot/rspec"

  Capybara::Screenshot.prune_strategy = :keep_last_run
  # From https://github.com/mattheworiordan/capybara-screenshot/issues/84#issuecomment-41219326
  Capybara::Screenshot.register_driver(:chrome) do |driver, path|
    driver.browser.save_screenshot(path)
  end
end

# Chrome driver
Capybara.register_driver :chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    # This enables access to logs with `page.driver.manage.get_log(:browser)`
    loggingPrefs: {
      browser: "ALL",
      client:  "ALL",
      driver:  "ALL",
      server:  "ALL"
    }
  )

  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("window-size=1280,720")
  options.add_argument("no-sandbox")
  options.add_argument("headless")
  options.add_argument("disable-gpu")

  Capybara::Selenium::Driver.new(
    app,
    browser:              :chrome,
    desired_capabilities: capabilities,
    options:              options
  )
end

# RSpec hooks
unless Containers.dockerized?
  RSpec.configure do |config|
    config.after(:example, :js) do |example|
      next unless ENV["DEBUG_JS"] || example.exception

      console = page.driver.browser.manage.logs.get(:browser)&.reject do |log|
        log.message =~ JS_CONSOLE_FILTER
      end

      p console.map(&:message).join("\n") if console.present?
    end
  end
end

# Poltergeist driver
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

# Capybara configuration
Capybara.configure do |config|
  config.javascript_driver = JAVASCRIPT_DRIVER
  config.default_max_wait_time = WAIT_TIME
  config.match = :one
  config.ignore_hidden_elements = true
  config.visible_text_only = true
  config.default_selector = :css
end
