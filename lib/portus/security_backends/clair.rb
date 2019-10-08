# frozen_string_literal: true

require "portus/security_backends/base"

# Docker images contain quite some empty blobs, and trying to upload them will
# fail.
EMPTY_LAYER_SHA = "sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4"

module Portus
  module SecurityBackend
    # Clair implements all security-related methods by using CoreOS' Clair
    # (https://github.com/coreos/clair)
    class Clair < ::Portus::SecurityBackend::Base
      # Returns the vulnerabilities that can be found for the given layers. In
      # order to do so, this method needs an authentication token that will be
      # used to post this images into Clair. Moreover, this method also needs
      # the URL of the registry, since it needs to pass this information to
      # Clair.
      def vulnerabilities(params)
        @token        = params[:token]
        @registry_url = params[:registry_url]

        # Filter out empty layers.
        @layers = params[:layers].reject { |digest| digest == EMPTY_LAYER_SHA }

        # We first post everything in reverse order, so parent layers are
        # available when inspecting vulnerabilities.
        @layers.reverse.each_index { |k| post_layer(k) }

        # Finally, according to Clair's documentation, requesting
        # vulnerabilities from the last child will give you all of them.
        layer_vulnerabilities(@layers.last)
      end

      def self.config_key
        "clair"
      end

      protected

      # Returns an array with all the vulnerabilities found by Clair for the
      # given digest.
      def layer_vulnerabilities(digest)
        layer = fetch_layer(digest)
        return [] if layer.nil?

        res = []
        known = []
        Array(layer["Features"]).each do |f|
          vulns = f["Vulnerabilities"]
          next if vulns.nil?

          vulns.each do |v|
            name = Hash(v)["Name"]
            next if name.blank? || known.include?(name)

            known << v["Name"]
            res << v
          end
        end
        res.sort_by { |el| el["Name"] }
      end

      # Fetches the layer information from Clair for the given digest as a Hash.
      # If nothing could be extracted, then nil is returned.
      def fetch_layer(digest)
        # Now we fetch the vulnerabilities discovered by clair on that layer.
        uri, req = get_request("/v1/layers/#{digest}?features=false&vulnerabilities=true", "get")
        req["Accept"] = "application/json"
        begin
          res = get_response_token(uri, req, clair_timeout)
        rescue *::Portus::Errors::NET => e
          Rails.logger.tagged("clair.get") { Rails.logger.debug e.message }
          return
        end

        # Parse the given response and return the result.
        if res.code.to_i == 200
          msg = JSON.parse(res.body)
          Rails.logger.tagged("clair.get") { Rails.logger.debug msg }
          msg["Layer"]
        else
          handle_response(res, digest, "clair.get")
        end
      end

      # Post the layer pointed by the given index to Clair.
      def post_layer(index)
        parent = index.positive? ? @layers.fetch(index - 1) : ""
        digest = @layers.fetch(index)

        uri, req = get_request("/v1/layers", "post")
        req.body = layer_body(digest, parent).to_json

        begin
          res = get_response_token(uri, req, clair_timeout)
        rescue *::Portus::Errors::NET => e
          Rails.logger.tagged("clair.post") { Rails.logger.debug e.message }
          return
        end

        handle_response(res, digest, "clair.post")
      end

      # Returns a hash that has to be used as the body of a POST request. This
      # method requires the digest of the layer to be pushed, and the digest of
      # the parent layer. If this layer has no parent, then it should be an
      # empty string.
      def layer_body(digest, parent)
        path = URI.join(@registry_url.to_s, "/v2/#{@repo}/blobs/#{digest}").to_s

        {
          "Layer" => {
            "Name"             => digest,
            "NamespaceName"    => "",
            "Path"             => path,
            "Headers"          => { "Authorization" => "Bearer #{@token}" },
            "ParentName"       => parent,
            "Format"           => "Docker",
            "IndexedByVersion" => 0,
            "Features"         => []
          }
        }
      end

      # Handle a response from a Clair request. The first parameter is the HTTP
      # response itself, the `digest` holds a string with the digest ID, and
      # finally `kind` is a string that identifies the kind of request.
      def handle_response(response, digest, kind)
        code = response.code.to_i
        Rails.logger.tagged(kind) { Rails.logger.debug "Handling code: #{code}" }
        return if code == 200 || code == 201

        msg = code == 404 ? response.body : error_message(JSON.parse(response.body))
        Rails.logger.tagged(kind) do
          Rails.logger.debug "Could not post '#{digest}': #{msg}"
        end

        nil
      end

      # Returns a proper error message for the given JSON response.
      def error_message(msg)
        msg["Error"] && msg["Error"]["Message"] ? msg["Error"]["Message"] : msg
      end

      # Returns the integer value of timeouts for HTTP requests.
      def clair_timeout
        APP_CONFIG["security"]["clair"]["timeout"]
      end
    end
  end
end
