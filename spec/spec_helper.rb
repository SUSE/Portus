# frozen_string_literal: true

require "simplecov"
require "webmock/rspec"
require "vcr"

SimpleCov.minimum_coverage 100
SimpleCov.start "rails" do
  # TODO: remove this when this feature is merged in zypper-docker's master branch.
  add_filter "lib/portus/security_backends/zypper"
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/vcr_cassettes"
  c.hook_into :webmock
  c.ignore_localhost = true

  # So code coverage reports can be submitted to codeclimate.com
  c.ignore_hosts "codeclimate.com"

  # To debug when a VCR goes wrong.
  c.debug_logger = $stdout if ENV["PORTUS_VCR_LOGGER"]
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
  config.before do
    Timecop.return

    # Clear the global config before each test.
    APP_CONFIG.clear

    # this value affects normal login behavior, reset to default value always.
    APP_CONFIG["oauth"] = { "local_login" => { "enabled" => true } }

    # this value affects the application controller, we have to make sure
    # it has the default value we expect
    APP_CONFIG["check_ssl_usage"] = { "enabled" => true }

    # Expected to be always available.
    APP_CONFIG["machine_fqdn"] = { "value" => "portus.test.lan" }

    # This value is expected to be always available. The default value will be
    # set
    APP_CONFIG["registry"] = {
      "jwt_expiration_time" => { "value" => 5   },
      "catalog_page"        => { "value" => 100 },
      "timeout"             => { "value" => 2   },
      "read_timeout"        => { "value" => 120 }
    }

    APP_CONFIG["user_permission"] = {
      # This allows non-admins to change the visibility of their personal namespace
      "change_visibility" => { "enabled" => true },
      # This allows non-admins to modify namespaces
      "manage_namespace"  => { "enabled" => true },
      # This allows non-admins to create namespaces
      "create_namespace"  => { "enabled" => true },
      # This allows non-admins to modify webhooks
      "manage_webhook"    => { "enabled" => true },
      # This allows non-admins to create webhooks
      "create_webhook"    => { "enabled" => true },
      # This allows non-admins to modify teams
      "manage_team"       => { "enabled" => true },
      # This allows non-admins to create teams
      "create_team"       => { "enabled" => true },
      # This allows non-admins to push images
      "push_images"       => { "policy" => "allow-teams" }
    }

    APP_CONFIG["security"] = {
      "clair" => {
        "server"  => "",
        "timeout" => 900
      }, "zypper" => {
        "server" => ""
      }, "dummy" => {
        "server" => ""
      }
    }

    APP_CONFIG["background"] = {
      "sync" => { "enabled" => false, "strategy" => "initial" }
    }

    APP_CONFIG["delete"] = {
      "enabled"           => false,
      "contributors"      => false,
      "garbage_collector" => {
        "enabled"    => false,
        "older_than" => 30,
        "tag"        => ""
      }
    }

    APP_CONFIG["pagination"] = {
      "per_page"     => 10,
      "before_after" => 2
    }

    APP_CONFIG["ldap"] = {
      "enabled"        => false,
      "hostname"       => "hostname",
      "port"           => 389,
      "timeout"        => 5,
      "encryption"     => {
        "method"  => "",
        "options" => {
          "ca_file"     => "",
          "ssl_version" => "TLSv1_2"
        }
      },
      "base"           => "ou=users,dc=example,dc=com",
      "base_admin"     => "",
      "filter"         => "",
      "uid"            => "uid",
      "group_sync"     => {
        "enabled"      => true,
        "default_role" => "viewer"
      },
      "authentication" => {
        "enabled"  => false,
        "bind_dn"  => "",
        "password" => ""
      },
      "guess_email"    => {
        "enabled" => false,
        "attr"    => ""
      }
    }

    Rails.cache.write("portus-checks", nil)
  end

  config.order = :random
end
