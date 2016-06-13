source "https://rubygems.org"

gem "rails", "~> 4.2.6"
gem "jquery-rails"
gem "sass-rails", ">= 3.2"
gem "slim"
gem "pundit"
gem "sprockets", "~> 2.12.3"
gem "jwt"
gem "base32"
gem "active_model_serializers"
gem "devise"
gem "gravatar_image_tag"
gem "public_activity"
gem "active_record_union"
gem "mysql2"
gem "search_cop"
gem "kaminari"
gem "crono"
gem "net-ldap"
gem "redcarpet"
gem "font-awesome-rails"
gem "bootstrap-typeahead-rails"
gem "rails_stdout_logging", "~> 0.0.5", group: [:development, :staging, :production]
gem "typhoeus"

# Used to store application tokens. This is already a Rails depedency. However
# better safe than sorry...
gem "bcrypt"

# This is already a Rails dependency, but we use it to run portusctl
gem "thor"

# Assets group.
#
# Do not set it or set it to no when precompiling the assets.
#
# IGNORE_ASSETS="no" RAILS_ENV=production bundle exec rake assets:precompile
#
# Set IGNORE_ASSETS to YES when creating the Gemfile.lock for
# production after having precompiled the assets
# run:
#
# IGNORE_ASSETS=yes bundle list
unless ENV["IGNORE_ASSETS"] == "yes"
  gem "coffee-rails"
  gem "bootstrap-sass", "~> 3.3.4"
  gem "uglifier"
  gem "jquery-turbolinks"
  gem "turbolinks"
end

# In order to create the Gemfile.lock required for packaging
# meaning that it should contain only the production packages
# run:
#
# PACKAGING=yes bundle list

unless ENV["PACKAGING"] && ENV["PACKAGING"] == "yes"
  group :development do
    gem "annotate"
    gem "rails-erd"
    gem "quiet_assets"
    gem "pry-rails"
    gem "git-review", require: false
    gem "rack-mini-profiler", require: false
    gem "guard", require: false
    gem "guard-rubocop", require: false
    gem "guard-rspec", require: false
  end

  group :development, :test do
    gem "byebug"
    gem "web-console", "~> 2.1.3"
    gem "puma"
    gem "awesome_print"
    gem "hirb"
    gem "wirb"
    gem "wirble"
    gem "factory_girl_rails"
    gem "ffaker"
    gem "rubocop", require: false
    gem "brakeman", require: false
    gem "database_cleaner"
  end

  group :test do
    gem "shoulda"
    gem "rspec-rails"
    gem "vcr"
    gem "webmock", require: false
    gem "simplecov", require: false
    gem "capybara"
    gem "poltergeist", require: false
    gem "json-schema"
    gem "timecop"
    gem "codeclimate-test-reporter", group: :test, require: nil
    gem "docker-api", "~> 1.28.0"
  end
end
