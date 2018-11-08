# frozen_string_literal: true

require "portus/http_helpers"

module Portus
  module HealthChecks
    # Clair offers health check support for CoreOS Clair.
    class Clair
      extend ::Portus::HttpHelpers

      def self.name
        "clair"
      end

      def self.ready
        server = APP_CONFIG["security"]["clair"]["server"]
        return [nil, false] if server.blank?

        uri = URI.join(health_endpoint(server), "/health")
        valid_scheme = uri.scheme == "http" || uri.scheme == "https"
        return ["clair is not reachable: neither HTTP nor HTTPS", false] unless valid_scheme

        req     = Net::HTTP::Get.new(uri)
        res     = get_response_token(uri, req)
        success = res.code.to_i == 200
        ["clair is#{success ? "" : " not"} reachable", success]
      rescue *::Portus::Errors::NET => e
        ["clair is not reachable: #{e.message}", false]
      end

      # It corrects the endpoint of the Clair server so it can be used to check
      # the health status.
      def self.health_endpoint(server)
        server = add_protocol(server)
        port = APP_CONFIG["security"]["clair"]["health_port"]
        if server.match?(/:(\d)+/)
          server.gsub(/:(\d)+/, ":#{port}")
        else
          "#{server}:#{port}"
        end
      end

      # add_protocol checks that the given server has a proper
      # protocol. Otherwise it will log a warning and assume "http".
      def self.add_protocol(server)
        return server if server.match? %r{^http(s)?://}

        Rails.logger.warn "You did not specify a protocol for the Clair server. Assuming http..."
        "http://#{server}"
      end
    end
  end
end
