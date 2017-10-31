source "https://rubygems.org"

ruby ">= 2.4"

gem "active_record_union"
gem "base32"
gem "bootstrap-sass", "~> 3.3.4"
gem "crono"
gem "devise"
gem "font-awesome-rails"
gem "grape"
gem "grape-entity"
gem "grape-swagger"
gem "grape-swagger-entity"
gem "gravatar_image_tag"
gem "hashie-forbidden_attributes"
gem "jwt"
gem "kaminari"
gem "net-ldap"
gem "omniauth-github"
gem "omniauth-gitlab"
gem "omniauth-google-oauth2"
gem "omniauth-openid"
gem "public_activity"
gem "pundit"
gem "rails", "~> 4.2.10"
gem "rails_stdout_logging", "~> 0.0.5", group: %i[development staging production]
gem "redcarpet", "~> 3.4.0"
gem "sass-rails", ">= 3.2"
gem "search_cop"
gem "slim", "~> 3.0.8"
gem "sprockets", "~> 2.12.3"
gem "webpack-rails"

gem "rack-cors", "~> 1.0.1"

# Supported DBs
gem "mysql2", "= 0.4.7", group: :mysql
gem "pg", "~> 0.20.0", group: :postgres

# Pinning these specific versions because that's what we have on OBS.
gem "ethon", "~> 0.9.0"
gem "typhoeus", "~> 1.0.2"

# Used to store application tokens.
gem "bcrypt"

# This is already a Rails dependency, but we use it to run portusctl
gem "thor", "~> 0.19.4"

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
gem "uglifier" unless ENV["IGNORE_ASSETS"] == "yes"

# Returns true if the bundle is targeted towards building a package.
def packaging?
  ENV["PACKAGING"] == "yes"
end

# If the deployment is done through Puma, include it in the bundle.
gem "puma", "~> 3.10.0" if ENV["PORTUS_PUMA_DEPLOYMENT"] == "yes" || !packaging?

# Configuration management
gem "cconfig", "~> 1.2.0"

# In order to create the Gemfile.lock required for packaging
# meaning that it should contain only the production packages
# run:
#
# PACKAGING=yes bundle list

unless packaging?
  group :development do
    gem "annotate"
    gem "git-review", require: false
    gem "guard", require: false
    gem "guard-rspec", require: false
    gem "guard-rubocop", require: false
    gem "jquery"
    gem "jquery-rails"
    gem "peek"
    gem "peek-gc"
    gem "peek-git"
    gem "peek-mysql2"
    gem "peek-performance_bar"
    gem "peek-pg"
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
    gem "md2man", "~>5.1.1", require: false
    gem "rubocop", "~> 0.51.0", require: false
    gem "web-console", "~> 2.1.3"
    gem "wirb"
    gem "wirble"
  end

  group :test do
    gem "capybara", "~> 2.14.3"
    gem "codeclimate-test-reporter", group: :test, require: nil
    gem "docker-api", "~> 1.28.0"
    gem "json-schema"
    gem "poltergeist", "~> 1.15.0", require: false
    gem "shoulda"
    gem "simplecov", "0.15.1", require: false
    gem "timecop"
    gem "vcr"
    gem "webmock", "~> 2.3.2", require: false
  end
end
