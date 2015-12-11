module Portus
  # NavaliaClient wraps navalia REST API into a class.
  class NavaliaClient
    include HttpHelpers

    def initialize(host, authorization_token = nil)
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

    # Returns the status of the builds as an array
    # The param ids is an array of build identifiers
    # These identifiers had been provided by the build method
    def status(ids)
      body = { "ids" => ids }
      req = perform_request("build", "get", true, http_headers, body.to_json)
      if req.code.to_i == 200
        JSON.parse(req.body)
      else
        raise "Something went wrong while fetching the navalia build status for #{@host}"
      end
    end

    # Delete builds
    def delete(ids)
      body = { "ids" => ids }
      req = perform_request("build", "delete", true, http_headers, body.to_json)
      raise "Something went wrong while deleting the navalia builds #{ids} for\
 #{@host}" unless req.code.to_i == 200
    end

    # Trigger a build
    #   url: url of the git repository where dockerfile resides
    #   registry: registry where to push
    #   image_id: image id to be used for pushing
    # It returns the id of the new build
    def build(url, registry, image_id)
      body = {
        "url"  => url,
        "push" => {
          "id"       => "registry",
          "hostname" => registry,
          "image"    => image_id
        }
      }
      req = perform_request("build", "post", true, http_headers, body.to_json)
      if req.code.to_i == 201
        JSON.parse(req.body)["id"]
      else
        raise "Something went wrong while triggering a navalia build on\
 #{@host}, for dockerfile in #{url} for registry #{registry} and image id\
 #{image_id}"
      end
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
