# frozen_string_literal: true

require "net/http"
require "portus/errors"
require "portus/request_error"

module Portus
  # Implements all the methods and classes that are needed by the RegistryClient.
  # This separation has been done because this module deals with HTTP helpers and
  # the authentication process. The RegistryClient class will just deal with each
  # endpoint of the API.
  module HttpHelpers
    include ::Portus::Errors

    # Returns an URI object and a request object for the given path & method
    # pair.
    def get_request(path, method)
      uri = URI.join(@base_url, path)
      req = Net::HTTP.const_get(method.capitalize).new(uri)
      [uri, req]
    end

    # This is the general method to perform an HTTP request to an endpoint
    # provided by the registry. The first parameter is the URI of the endpoint
    # itself. The second parameter is the HTTP method in downcase (e.g. "post").
    # It defaults to "get", which is what we usually perform in this application.
    # The `request_auth_token` parameter means that if this method gets a 401
    # when calling the given path, it should get an authorization token
    # automatically and try again.
    def perform_request(path, method = "get", request_auth_token = true)
      uri, req = get_request(path, method)

      # So we deal with compatibility issues in distribution 2.3 and later.
      # See: https://github.com/docker/distribution/blob/master/docs/compatibility.md#content-addressable-storage-cas
      req["Accept"] = "application/vnd.docker.distribution.manifest.v2+json"

      # This only happens if the auth token has already been set by a previous
      # call.
      req["Authorization"] = "Bearer #{@token}" if @token

      res = get_response_token(uri, req)
      if res.code.to_i == 401
        # This can mean that this is the first time that the client is calling
        # the registry API, and that, therefore, it might need to request the
        # authorization token first.
        if request_auth_token
          # Note that request_auth_token will raise an exception on error.
          request_auth_token(res)

          # Recursive call, but this time we make sure that we don't enter here
          # again. If this call fails, then there's something *really* wrong with
          # the given credentials.
          return perform_request(path, method, false)
        end
      end
      res
    end

    # safe_quest simply calls perform_request and wraps any kind of exception
    # into a RequestError. This way, callers don't have to check for the myriad
    # of exceptions that an HTTP request might entail.
    def safe_request(path, method = "get", request_auth_token = true)
      perform_request(path, method, request_auth_token)
    rescue *::Portus::Errors::NET => e
      message = ::Portus::Errors.message_from_exception(e)
      raise ::Portus::RequestError.new(exception: e, message: message)
    end

    # Handle a known error from Docker distribution. Typically these are
    # responses that have an HTTP code of 40x. The given response is the raw
    # response as given by the registry, and the params hash are extra arguments
    # that will be passed to the exception message.
    def handle_error(response, params = {})
      str = "\nCode: #{response.code}\n"

      # Add the errors as given by the registry.
      begin
        body = JSON.parse(response.body)
        if body["errors"]
          str += "Reported by Registry:\n"
          body["errors"].each { |err| str += "#{err}\n" }
          str += "\n"
        end
      rescue JSON::ParserError
        str += "Body:\n#{response.body}\n\n"
      end

      # Add the defined parameters.
      unless params.empty?
        str += "Passed values:\n"
        params.each { |k, v| str += "#{k}: #{v}\n" }
        str += "\n"
      end

      raise ::Portus::Errors::NotFoundError, str
    end

    private

    # Returns true if this client has the credentials set.
    def credentials?
      @username && @password
    end

    # This method should be called after getting a 401. In this case, the
    # registry has sent the proper "WWW-Authenticate" header value that will
    # allow us the request a new authorization token for this client.
    def request_auth_token(unhauthorized_response)
      bearer_realm, query = parse_unhauthorized_response(unhauthorized_response)
      uri = URI("#{bearer_realm}?#{query.to_query}")

      req = Net::HTTP::Get.new(uri)
      req.basic_auth(@username, @password) if credentials?

      res = get_response_token(uri, req)
      if res.code.to_i == 200
        @token = JSON.parse(res.body)["token"]
      else
        @token = nil
        raise AuthorizationError, "Cannot obtain authorization token: #{res}"
      end
    end

    # For the given 401 response, try to extract the token and the parameters
    # that this client should use in order to request an authorization token.
    def parse_unhauthorized_response(res)
      auth_args = res.to_hash["www-authenticate"].first.split(",").each_with_object({}) do |i, h|
        key, val = i.split("=")
        h[key] = val.delete('"')
      end

      unless credentials?
        raise CredentialsMissingError, "Registry #{@host} has authorization enabled, "\
          "user credentials not specified"
      end

      query_params = {
        "service" => auth_args["service"],
        "account" => @username
      }
      query_params["scope"] = auth_args["scope"] if auth_args.key?("scope")

      unless auth_args.key?("Bearer realm")
        raise(NoBearerRealmException, "Cannot find bearer realm")
      end

      [auth_args["Bearer realm"], query_params]
    end

    # Performs an HTTP request to the given URI and request object. You may
    # optionally pass a read and open timeout, otherwise the ones provided in
    # the `registry` config will be used. It returns an HTTP response that has
    # been sent from the registry.
    def get_response_token(uri, req, timeout = nil)
      open, read = if timeout
                     [timeout, timeout]
                   else
                     [APP_CONFIG["registry"]["timeout"]["value"],
                      APP_CONFIG["registry"]["read_timeout"]["value"]]
                   end

      options = {
        use_ssl:      uri.scheme == "https",
        open_timeout: open.to_i,
        read_timeout: read.to_i
      }

      Net::HTTP.start(uri.hostname, uri.port, options) do |http|
        http.request(req)
      end
    end
  end
end
