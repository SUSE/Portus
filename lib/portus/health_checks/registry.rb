# frozen_string_literal: true

module Portus
  module HealthChecks
    # Registry offers health check support for the configured Docker
    # registry. Note that this will also fail if the registry is up and running
    # but there's something wrong with the configuration (e.g. SSL problem).
    class Registry
      def self.name
        "registry"
      end

      def self.ready
        return ["no registry configured", false] unless ::Registry.any?

        res = ::Registry.get.client.reachable?
        ["registry is#{res ? "" : " not"} reachable", res]
      rescue ::Portus::RequestError => e
        [e.to_s, false]
      end
    end
  end
end
