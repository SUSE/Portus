# frozen_string_literal: true

# :nocov:
require "portus/security_backends/base"

module Portus
  module SecurityBackend
    # NOTE: support for this is experimental since this functionality has not
    # been merged into master yet in zypper-docker.
    class Zypper < ::Portus::SecurityBackend::Base
      # Returns the vulnerabilities as given by a zypper-docker server. It can
      # return two different types:
      #   - An array containing the vulnerabilities found.
      #   - nil if zypper-docker is still working on it.
      def vulnerabilities(_params)
        uri, req = get_request("/images?image=#{@repo}:#{@tag}")
        res = get_response_token(uri, req)

        msg = JSON.parse(res.body)
        if res.code.to_i == 200
          consume_response(msg)
        elsif res.code.to_i == 202
          nil
        else
          msg = error_message(msg)
          Rails.logger.tagged("zypper") do
            Rails.logger.debug "Error for '#{@repo}:#{@tag}': #{msg}"
          end
          nil
        end
      end

      def self.config_key
        "zypper"
      end

      protected

      def consume_response(response)
        security = response["Security"]
        return [] if security.nil? || security.to_i.zero?

        res = []
        response["List"].each do |issue|
          res << issue if issue["IsSecurity"]
        end
        res
      end

      def error_message(msg)
        msg["Error"] || msg
      end
    end
  end
end
# :nocov:
