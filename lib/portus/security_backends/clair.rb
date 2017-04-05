require "portus/security_backends/base"

# Docker images contain quite some empty blobs, and trying to upload them will
# fail.
EMPTY_LAYER_SHA = "sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4".freeze

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

      protected

      # Returns an array with all the vulnerabilities found by Clair for the
      # given digest.
      def layer_vulnerabilities(digest)
        layer = fetch_layer(digest)
        return [] if layer.nil?

        res = []
        known = []
        layer["Features"].each do |f|
          vulns = f["Vulnerabilities"]
          next if vulns.nil?

          vulns.each do |v|
            if v && v["Name"] && !known.include?(v["Name"])
              known << v["Name"]
              res << v
            end
          end
        end
        res
      end

      # Fetches the layer information from Clair for the given digest as a Hash.
      # If nothing could be extracted, then nil is returned.
      def fetch_layer(digest)
        # Now we fetch the vulnerabilities discovered by clair on that layer.
        uri, req = get_request("/v1/layers/#{digest}?features=false&vulnerabilities=true", "get")
        res = get_response_token(uri, req)

        # Parse the given response and return the result.
        msg = JSON.parse(res.body)
        if res.code.to_i == 200
          msg["Layer"]
        else
          msg = error_message(msg)
          Rails.logger.tagged("clair.get") { Rails.logger.debug "Error for '#{digest}': #{msg}" }
          nil
        end
      end

      # Post the layer pointed by the given index to Clair.
      def post_layer(index)
        parent = index > 0 ? @layers.fetch(index - 1) : ""
        digest = @layers.fetch(index)

        uri, req = get_request("/v1/layers", "post")
        req.body = layer_body(digest, parent).to_json

        res = get_response_token(uri, req)
        if res.code.to_i != 200 && res.code.to_i != 201
          msg = error_message(JSON.parse(res.body))
          Rails.logger.tagged("clair.post") do
            Rails.logger.debug "Could not post '#{digest}': #{msg}"
          end
        end
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

      # Returns a proper error message for the given JSON response.
      def error_message(msg)
        msg["Error"] && msg["Error"]["Message"] ? msg["Error"]["Message"] : msg
      end
    end
  end
end
