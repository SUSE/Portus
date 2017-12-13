# frozen_string_literal: true

require "portus/http_helpers"

module Portus
  module SecurityBackend
    # Base implements basic functionality that each security backend should
    # have. All security backends should subclass this one.
    class Base
      include ::Portus::HttpHelpers

      def initialize(repo, tag)
        @repo     = repo
        @tag      = tag
        @base_url = self.class.configuration["server"]
      end

      # Returns true if the given backend has been enabled, false otherwise.
      def self.enabled?
        cfg = configuration
        cfg["server"].present?
      end

      # Returns the configuration of the given backend.
      def self.configuration
        n = name.to_s.demodulize.downcase
        APP_CONFIG["security"][n]
      end
    end
  end
end
