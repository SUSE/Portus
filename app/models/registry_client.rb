# RegistryClient is a a layer between Portus and the Registry. Given a set of
# credentials, it's able to call to any endpoint in the registry API. Moreover,
# it also implements some handy methods on top of some of these endpoints (e.g.
# the `manifest` method for the Manifest API endpoints).
class RegistryClient
  # As specified in the token specification of distribution, the client will
  # get a 401 on the first attempt of logging in, but in there should be the
  # "WWW-Authenticate" header. This exception will be raised when there's no
  # authentication token bearer.
  class NoBearerRealmException < RuntimeError; end

  # Raised when the authorization token could not be fetched.
  class AuthorizationError < RuntimeError; end

  # Used when a resource was not found for the given endpoint.
  class NotFoundError < RuntimeError; end

  # Raised if this client does not have the credentials to perform an API call.
  class CredentialsMissingError < RuntimeError; end

  def initialize(host, use_ssl = true, username = nil, password = nil)
    @host = host
    @use_ssl = use_ssl
    @base_url = "http#{"s" if @use_ssl}://#{@host}/v2/"
    @username = username
    @password = password
  end

  # Retrieves the manifest for the required repository:tag. If everything goes
  # well, it will return a parsed response from the registry, otherwise it will
  # raise either ManifestNotFoundError or a RuntimeError.
  def manifest(repository, tag = "latest")
    res = get_request("#{repository}/manifests/#{tag}")
    if res.code.to_i == 200
      JSON.parse(res.body)
    elsif res.code.to_i == 404
      raise NotFoundError, "Cannot find manifest for #{repository}:#{tag}"
    else
      raise "Something went wrong while fetching manifest for " \
        "#{repository}:#{tag}:[#{res.code}] - #{res.body}"
    end
  end

  # Fetches all the repositories available in the registry, with all their
  # corresponding tags. If something goes wrong while fetching the repos from
  # the catalog (e.g. authorization error), it will raise an exception.
  #
  # Returns an array of hashes which contain two keys:
  #   - name: a string containing the name of the repository.
  #   - tags: an array containing the available tags for the repository.
  def catalog
    res = get_request("_catalog")
    if res.code.to_i == 200
      catalog = JSON.parse(res.body)
      add_tags(catalog["repositories"])
    elsif res.code.to_i == 404
      raise NotFoundError, "Could not find the catalog endpoint!"
    else
      raise "Something went wrong while fetching the catalog"
    end
  end

  # This is the general method to perform a GET request to an endpoint provided
  # by the registry. The first parameter is the URI of the endpoint itself. The
  # `request_auth_token` parameter means that if this method gets a 401 when
  # calling the given path, it should get an authorization token automatically
  # and try again.
  def get_request(path, request_auth_token = true)
    uri = URI.join(@base_url, path)
    req = Net::HTTP::Get.new(uri)

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
        return get_request(path, false)
      end
    end
    res
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
      h[key] = val.gsub('"', "")
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

  # Performs an HTTP request to the given URI and request object. It returns an
  # HTTP response that has been sent from the registry.
  def get_response_token(uri, req)
    https = uri.scheme == "https"
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: https) do |http|
      http.request(req)
    end
  end

  # Adds the available tags for each of the given repositories. If there is a
  # problem while fetching a repository's tag, it will return an empty array.
  # Otherwise it will return an array with the results as specified in the
  # documentation of the `catalog` method.
  def add_tags(repositories)
    return [] if repositories.nil?

    result = []
    repositories.each do |repo|
      res = get_request("#{repo}/tags/list")
      return [] if res.code.to_i != 200
      result << JSON.parse(res.body)
    end
    result
  end
end
