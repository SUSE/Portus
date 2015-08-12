source "https://rubygems.org"

gem "rails", "~> 4.2.2"
gem "jquery-rails", "~> 4.0.4"
gem "turbolinks"
gem "slim"
gem "coffee-rails"
gem "bootstrap-sass", "~> 3.3.4"
gem "sass-rails", ">= 3.2"
gem "uglifier"
gem "pundit"
gem "sprockets", "~> 2.12.3"
gem "jwt"
gem "base32"
gem "active_model_serializers"
gem "devise"
gem "jquery-turbolinks"
gem "gravatar_image_tag"
gem "rails-observers"
gem "public_activity"
gem "active_record_union"
gem "mysql2"
gem "search_cop"
gem "kaminari"
gem "crono"

# In order to create the Gemfile.lock required for packaging
# meaning that it should contain only the production packages
# run:
#
# PACKAGING=yes bundle list

unless ENV["PACKAGING"] && ENV["PACKAGING"] == "yes"

  group :development do
    gem "quiet_assets"
    gem "pry-rails"
    gem "git-review", require: false
    gem "rack-mini-profiler", require: false
  end

  group :development, :test do
    gem "byebug"
    gem "web-console", "~> 2.1.3"
    gem "thin"
    gem "awesome_print"
    gem "hirb"
    gem "wirb"
    gem "wirble"
    gem "factory_girl_rails"
    gem "ffaker"
    gem "rubocop", require: false
  end

  group :test do
    gem "shoulda"
    gem "rspec-rails"
    gem "vcr"
    gem "webmock", require: false
    gem "simplecov", require: false
    gem "capybara"
    gem "poltergeist", require: false
    gem "database_cleaner"
    gem "json-schema"
    gem "timecop"
    gem "codeclimate-test-reporter", group: :test, require: nil
  end

end
