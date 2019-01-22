# frozen_string_literal: true

require "portus/cmd"
require "portus/test"

# There are three cases for the matrix:
#
# 1. No CI: both development and production images will be used.
# 2. CI and it's a pull request: only the development image will be used.
# 3. CI and it's not a pull request: only production images will be used.
#
# In all cases they will test against registry 2.5 and 2.6.

# Images for the supported registry versions. These versions will be applied
# through a cartesian product into the test matrix.
SUPPORTED_REGISTRIES = [
  "library/registry:2.5",
  "library/registry:2.6",
  "library/registry:2.7.1"
].freeze

PRODUCTION = [
  {
    background: "opensuse/portus:head",
    portus:     "opensuse/portus:head"
  }
].freeze

matrix = if ENV["CI"].present?
           ENV["TRAVIS_PULL_REQUEST"] == "false" ? PRODUCTION.dup : [{}]
         else
           [{}] + PRODUCTION.dup
         end

MATRIX = matrix.product(SUPPORTED_REGISTRIES).map { |v| v.first.merge(registry: v.last) }.freeze

namespace :test do
  desc "Run the integration test suite"
  task run: :environment do
    status = 0

    MATRIX.each do |env|
      str = env.map { |k, v| "#{k}##{v}" }.join(" ")
      puts "[integration] Environment string: #{str}"

      # Don't build the image for Travis on master.
      if ENV["CI"].present? && ENV["TRAVIS_PULL_REQUEST"] == "false"
        ENV["PORTUS_INTEGRATION_BUILD_IMAGE"] = "false"
      end

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
