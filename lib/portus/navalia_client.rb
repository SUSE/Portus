module Portus
  # NavaliaClient wraps navalia REST API into a class.
  class NavaliaClient
    include HttpHelpers

    def initialize(host, authorization_token)
      @host = host
      @authorization_token = authorization_token
      @base_url = "http://#{@host}"
    end

    # Returns whether the registry is reachable with the given credentials or
    # not.
    def reachable?
      !perform_request("/ping").nil?
    rescue
      false
    end

    # Returns the status of the builds
    def status(ids)
      body = { "ids" => ids }
      perform_request("build", "get", true, http_headers, body.to_json)
    end

    # Delete builds
    def delete(ids)
      body = { "ids" => ids }
      perform_request("build", "delete", true, http_headers, body.to_json)
    end

    # Trigger a build
    def build(url, registry, image_id)
      body = {
        "url"  => url,
        "push" => {
          "id"       => "registry",
          "hostname" => registry,
          "image"    => image_id
        }
      }
      perform_request("build", "post", true, http_headers, body.to_json)
    end

    private

    # Returns the http headers
    def http_headers
      # FIXME: set authorization
      {
        "API-Version"   => "1",
        "Content-Type"  => "application/json",
        "Authorization" => "#{@authorization_token}"
      }
    end
  end
end
