require "portus/security_backends/base"

module Portus
  module SecurityBackend
    class Zypper < ::Portus::SecurityBackend::Base
      # Returns the vulnerabilities as given by a zypper-docker server. It can
      # return two different types:
      #   - An array containing the vulnerabilities found.
      #   - nil if zypper-docker is still working on it.
      def vulnerabilities(repo, tag)
        uri, req = get_request("/images?image=#{repo}:#{tag}")
        res = get_response_token(uri, req)

        msg = JSON.parse(res.body)
        if res.code.to_i == 200
          consume_response(msg)
        elsif res.code.to_i == 202
          nil
        else
          msg = error_message(msg)
          Rails.logger.tagged("zypper") { Rails.logger.debug "Error for '#{repo}:#{tag}': #{msg}" }
          nil
        end
      end

      protected

      def consume_response(response)
        security = response["Security"]
        return [] if security.nil? || security.to_i == 0

        res = []
        response["List"].each do |issue|
          res << issue if issue["IsSecurity"]
        end
        res
      end

      def error_message(msg)
        msg["Error"] ? msg["Error"] : msg
      end
    end
  end
end
