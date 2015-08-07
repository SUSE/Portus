class RegistryClient
  class NoBearerRealmException < RuntimeError; end
  class AuthorizationError < RuntimeError; end
  class ManifestNotFoundError < RuntimeError; end
  class CredentialsMissingError < RuntimeError; end

  def initialize(host, use_ssl = true, username = nil, password = nil)
    @host = host
    @use_ssl = use_ssl
    @base_url = "http#{"s" if @use_ssl}://#{@host}/v2/"
    @username = username
    @password = password
  end

  def credentials?
    @username && @password
  end

  def manifest(repository, tag = "latest")
    res = get_request("#{repository}/manifests/#{tag}")
    if res.code.to_i == 200
      JSON.parse(res.body)
    elsif res.code.to_i == 404
      raise ManifestNotFoundError, "Cannot find manifest for #{repository}:#{tag}"
    else
      raise "Something went wrong while fetching manifest for #{repository}:#{tag}:" \
        "[#{res.code}] - #{res.body}"
    end
  end

  def get_request(path, request_auth_token = true)
    uri = URI.join(@base_url, path)
    Rails.logger.info uri
    Rails.logger.info "Token -> #{@token} <-"
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{@token}" if @token

    res = get_response_token(uri, req)
    if res.code.to_i == 401
      # Note that request_auth_token will raise an exception on error.
      if request_auth_token
        request_auth_token(res)
        return get_request(path, false)
      end
    else
      res
    end
  end

  private

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
end
