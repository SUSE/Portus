# frozen_string_literal: true

require File.expand_path("../boot", __FILE__)

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Portus
  # Application implements the Rails application base for Portus.
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = ENV["TZ"] || "UTC"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.autoload_paths << Rails.root.join("lib")
    config.autoload_paths << Rails.root.join("app", "validators")
    config.eager_load_paths << Rails.root.join("lib")
    config.eager_load_paths << Rails.root.join("app", "validators")
    config.exceptions_app = routes

    config.generators do |g|
      g.template_engine :slim
      g.test_framework :rspec
      g.fixture_replacement :factory_girl

      g.fallbacks[:rspec] = :test_unit
    end

    config.middleware.use Rack::Deflater

    # Allow access to the Portus API from other domains. This code is based on
    # Gitlab CE.
    config.middleware.insert_before Warden::Manager, Rack::Cors do
      allow do
        origins APP_CONFIG["machine_fqdn"]["value"]
        resource "/api/*",
                 credentials: true,
                 headers:     :any,
                 methods:     :any,
                 expose:      ["Link", "X-Total", "X-Total-Pages", "X-Per-Page",
                               "X-Page", "X-Next-Page", "X-Prev-Page"]
      end

      # Cross-origin requests must not have the session cookie available
      allow do
        origins "*"
        resource "/api/*",
                 credentials: false, # See the `credentials` in https://github.com/cyu/rack-cors#origin
                 headers:     :any,
                 methods:     :any,
                 expose:      ["Link", "X-Total", "X-Total-Pages", "X-Per-Page",
                               "X-Page", "X-Next-Page", "X-Prev-Page"]
      end
    end

    # Configure webpack
    config.webpack.config_file = "config/webpack.js"
    config.webpack.output_dir  = "public/assets/webpack"
    config.webpack.public_path = "assets/webpack"
    config.webpack.dev_server.enabled = false

    config.middleware.insert_before "ActionDispatch::ParamsParser", "CatchJsonParseErrors"
  end
end
