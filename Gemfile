# frozen_string_literal: true

source "https://rubygems.org"

gem "active_record_union"
gem "base32"
gem "devise"
gem "font-awesome-rails", "~> 4.7.0.1"
gem "grape"
gem "grape-entity"
gem "grape-swagger"
gem "grape-swagger-entity"
gem "gravatar_image_tag"
gem "hashie-forbidden_attributes"
gem "jwt"
gem "kaminari"
gem "net-ldap", "~> 0.16.1"
gem "omniauth-github"
gem "omniauth-gitlab"
gem "omniauth-google-oauth2"
gem "omniauth-openid"
gem "public_activity"
gem "pundit"
gem "rails", "~> 4.2.10"
gem "rails_stdout_logging", "~> 0.0.5", group: %i[development staging production]
gem "redcarpet", "~> 3.4.0"
gem "sass", "~> 3.4.23"
gem "search_cop"
gem "slim", "~> 3.0.8"
gem "webpack-rails"

gem "rack-cors", "~> 1.0.1"

# Supported DBs
gem "mysql2", "= 0.4.10", group: :db
gem "pg", "~> 0.20.0", group: :db

# Pinning these specific versions because that's what we have on OBS.
gem "ethon", "~> 0.9.0"
gem "typhoeus", "~> 1.0.2"

# Used to store application tokens.
gem "bcrypt", "~> 3.1.11"

# If the deployment is done through Puma, include it in the bundle.
gem "puma", "~> 3.10.0"

# Configuration management
gem "cconfig", "~> 1.2.0"

# Pinning some versions
gem "i18n", "= 0.8.0"
gem "ice_nine", "~> 0.11.2"
gem "minitest", "= 5.10.1"
gem "multi_json", "~> 1.12.1"
gem "rails-dom-testing", "~> 1.0.8"
gem "sprockets", "= 3.7.2"
gem "sprockets-rails", "~> 3.2.0"
gem "temple", "= 0.7.7"

##
# The following groups will *not* be included on the production installation.

group :assets do
  gem "bootstrap-sass", "~> 3.3.4"
  gem "sass-rails", "~> 5.0.6"
  gem "uglifier", "~> 4.1.3"
end

group :development do
  gem "annotate"
  gem "git-review", require: false
  gem "guard", require: false
  gem "guard-rspec", require: false
  gem "guard-rubocop", require: false
  gem "pry-rails"
  gem "quiet_assets"
  gem "rack-mini-profiler", require: false
  gem "rails-erd"
end

group :development, :test do
  gem "rspec-core", "~> 3.7.0"
  gem "rspec-rails"

  gem "awesome_print"
  gem "binman", "~>5.1.0"
  gem "brakeman", require: false
  gem "byebug"
  gem "database_cleaner"
  gem "factory_girl_rails"
  gem "ffaker"
  gem "grape-swagger-rails"
  gem "hirb"
  gem "rubocop", "~> 0.53.0", require: false
  gem "web-console", "~> 2.1.3"
  gem "wirb"
  gem "wirble"
end

group :test do
  gem "capybara", "~> 2.14.3"
  gem "capybara-screenshot", "~> 1.0.0"
  gem "chromedriver-helper"
  gem "codeclimate-test-reporter", require: false
  gem "docker-api", "~> 1.28.0"
  gem "json-schema"
  gem "poltergeist", "~> 1.18.0", require: false
  gem "selenium-webdriver", "~> 3.12"
  gem "shoulda"
  gem "simplecov", "0.15.1", require: false
  gem "timecop"
  gem "vcr"
  gem "webmock", "~> 2.3.2", require: false
end
