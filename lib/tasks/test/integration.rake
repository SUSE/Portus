# frozen_string_literal: true

require "portus/cmd"
require "portus/test"

# TODO: on a Travis PR, only test portus:development and registry:2.{5,6}
# TODO: otherwise, test with portus:2.3 and portus:head

# Images for the supported registry versions. These versions will be applied
# through a cartesian product into the test matrix.
SUPPORTED_REGISTRIES = [
  "library/registry:2.5",
  "library/registry:2.6"
].freeze

MATRIX = [
  # Development
  {},

  # Stable release: 2.3
  {
    background: "opensuse/portus:2.3",
    portus:     "opensuse/portus:2.3"
  },

  # Master.
  {
    background: "opensuse/portus:head",
    portus:     "opensuse/portus:head"
  }
].product(SUPPORTED_REGISTRIES).map { |v| v.first.merge(registry: v.last) }.freeze

namespace :test do
  desc "Run the integration test suite"
  task integration: :environment do
    status = 0

    MATRIX.each do |env|
      str = env.map { |k, v| "#{k}##{v}" }.join(" ")
      puts "[integration] Environment string: #{str}"

      # Don't build the image multiple times on Travis.
      ENV["PORTUS_INTEGRATION_BUILD_IMAGE"] = "false" if ENV["CI"].present?

      ENV["PORTUS_TEST_INTEGRATION"] = str if str.present?
      ENV["TEARDOWN_TESTS"] = "true"

      script = Rails.root.join("bin", "test-integration.sh")
      success = ::Portus::Cmd.spawn("/bin/bash #{script}")

      unless success
        status = 1
        puts "[integration] Allowed failure. Ignoring..." if ::Portus::Test.allow_failure?(env)
      end
    end

    exit status
  end
end
