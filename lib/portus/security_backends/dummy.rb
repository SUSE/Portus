# frozen_string_literal: true

# :nocov:
require "portus/security_backends/base"

module Portus
  module SecurityBackend
    # Dummy implements a backend that simply returns fixture data. This backend
    # is meant to be used only for development/testing purposes.
    class Dummy < ::Portus::SecurityBackend::Base
      # Files stored in `lib/portus/security_backends/fixtures`.
      DUMMY_FIXTURE = "dummy.json"

      # Whether the response from the `vulnerabilities` method should be as
      # "Working in Progress".
      WIP = false

      # Returns nil if the dummy backend is "working on it", otherwise it
      # returns a list of vulnerabilities as specified by the DUMMY_FIXTURE
      # constant.
      def vulnerabilities(_params)
        return nil if WIP

        path = Rails.root.join("lib", "portus", "security_backends", "fixtures", DUMMY_FIXTURE)
        JSON.parse(File.read(path))
      end

      def self.config_key
        "dummy"
      end
    end
  end
end
# :nocov:
