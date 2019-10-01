# frozen_string_literal: true

require "portus/security_backends/base"

module Portus
  module SecurityBackend
    # Anchore implements all security-related methods by using Anchore Engine
    # (https://github.com/anchore/anchore-engine)
    class Anchore < ::Portus::SecurityBackend::Base

      def initialize(repo, tag, digest)
        super(repo, tag, digest)
        @username = APP_CONFIG["security"]["anchore"]["username"]
        @password = APP_CONFIG["security"]["anchore"]["password"]
      end

      def vulnerabilities(params)

        @registry = params[:host]

        # Check that Anchore has done at least it's first full sync, so we don't
        # return an empty (no vuln) result, rather nil which means in-progress.
        uri, req = get_request("/v1/system/feeds", "get")
        req["Accept"] = "application/json"
        req.basic_auth(@username, @password)
        begin
          res = get_response_token(uri, req)
        rescue *::Portus::Errors::NET => e
          Rails.logger.tagged("anchore.get") { Rails.logger.debug e.message }
          return
        end

        if res.code.to_i != 200
          handle_response(res, @digest, "anchore.post")
          return
        end

        msg = JSON.parse(res.body)
        if msg.select {| feed| feed["name"] == "vulnerabilities" and feed["last_full_sync"] }.empty?
          return nil
        end

        # Now we fetch the vulnerabilities discovered by Anchore on that digest.
        uri, req = get_request("/v1/images/#{@digest}/vuln/all", "get")
        req["Accept"] = "application/json"
        req.basic_auth(@username, @password)
        begin
          res = get_response_token(uri, req)
        rescue *::Portus::Errors::NET => e
          Rails.logger.tagged("anchore.get") { Rails.logger.debug e.message }
          return
        end

        # Parse the given response and return the result.
        if res.code.to_i == 200
          msg = JSON.parse(res.body)
          Rails.logger.tagged("anchore.get") { Rails.logger.debug msg }
          vulnerabilities = msg["vulnerabilities"]
          vulnerabilities.map do |v|
            { "Name" => v["vuln"], "Link" => v["url"], "Severity" => v["severity"] }
          end
        elsif res.code.to_i == 404
          uri, req = get_request("/v1/images", "post")
          req["Accept"] = "application/json"
          req["Content-Type"] = "application/json"
          req.basic_auth(@username, @password)
          req.body = {tag: "#{@registry}/#{@repo}:#{@tag}"}.to_json
          begin
            res = get_response_token(uri, req)
            handle_response(res, @digest, "anchore.post")
            return
          rescue *::Portus::Errors::NET => e
            Rails.logger.tagged("anchore.post") { Rails.logger.debug e.message }
            return
          end
        else
          handle_response(res, @digest, "anchore.get")
        end
      end

      def self.config_key
        "anchore"
      end

      def handle_response(response, digest, kind)
        code = response.code.to_i
        Rails.logger.tagged(kind) { Rails.logger.debug "Handling code: #{code}" }
        return if code == 200 || code == 201

        msg = response.body
        Rails.logger.tagged(kind) do
          Rails.logger.debug "Could not post '#{digest}': #{msg}"
        end

        nil
      end
    end
  end
end
