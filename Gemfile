source 'https://rubygems.org'

gem 'rails', '~> 4.2.1'
gem 'therubyracer'
gem 'less-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'slim'
gem 'coffee-rails'
gem 'twitter-bootstrap-rails' #, github: 'seyhunak/twitter-bootstrap-rails', ref: '67f160dd'
gem 'sass-rails'
gem 'uglifier'
gem 'pundit'
# TODO: wait for sprockets 3.0 support
# https://github.com/metaskills/less-rails/issues/100
gem 'sprockets', '~> 2.12.3'
gem 'jwt'
gem 'base32'
gem 'active_model_serializers'
gem 'devise'
gem 'jquery-turbolinks'
gem 'gravatar_image_tag'
gem 'rails-observers'
gem 'public_activity'
gem 'active_record_union'
gem 'rotp'

gem 'pg'
# TODO: temporary
gem 'sqlite3'
gem 'sequel'

# In order to create the Gemfile.lock required for packaging
# meaning that it should contain only the production packages
# run:
#
# PACKAGING=yes bundle list

unless ENV['PACKAGING'] && ENV['PACKAGING'] == "yes"

  group :development do
    gem 'quiet_assets'
    gem 'pry-rails'
    gem 'git-review', require: false
    gem 'rack-mini-profiler', require: false
  end

  group :development, :test do
    gem 'byebug'
    gem 'web-console', '~> 2.0.0.beta4'
    gem 'thin'
    gem 'awesome_print'
    gem 'hirb'
    gem 'wirb'
    gem 'wirble'
    gem 'factory_girl_rails'
    gem 'ffaker'
    gem 'rubocop', '~> 0.27.1', require: false
  end

  group :test do
    gem 'shoulda'
    gem 'rspec-rails'
    gem 'vcr'
    gem 'webmock', require: false
    gem 'simplecov', require: false
    gem 'capybara'
    gem 'poltergeist', require: false
    gem 'database_cleaner'
    gem 'json-schema'
    gem 'timecop'
  end

end
