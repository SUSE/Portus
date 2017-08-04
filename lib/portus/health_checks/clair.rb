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

        uri     = URI.join(health_endpoint(server), "/health")
        req     = Net::HTTP::Get.new(uri)
        res     = get_response_token(uri, req)
        success = res.code.to_i == 200
        ["clair is#{success ? "" : " not"} reachable", success]

      rescue SocketError, Errno::ECONNREFUSED => e
        ["clair is not reachable: #{e.message}", false]
      end

      # It corrects the endpoint of the Clair server so it can be used to check
      # the health status.
      def self.health_endpoint(server)
        port = APP_CONFIG["security"]["clair"]["health_port"]

        if server =~ /:(\d)+/
          server.gsub(/:(\d)+/, ":#{port}")
        else
          "#{server}:#{port}"
        end
      end
    end
  end
end
