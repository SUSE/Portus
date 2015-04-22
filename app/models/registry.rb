class Registry
  class NoBearerRealmException < RuntimeError
  end

  class AuthorizationError < RuntimeError
  end

  class ManifestNotFoundError < RuntimeError
  end

  class CredentialsMissingError < RuntimeError
  end

  def initialize(host, use_ssl=true, username=nil, password=nil)
    @host = host
    @use_ssl = use_ssl
    @base_url = "http#{'s' if @use_ssl}://#{@host}/v2/"
    @username = username
    @password = password
  end

  def has_credentials?
    @username && @password
  end

  def manifest(repository, tag='latest')
    res = get_request("#{repository}/manifests/#{tag}")
    if res.code.to_i == 200
      JSON.parse(res.body)
    elsif res.code.to_i == 404
      fail ManifestNotFoundError, "Cannot find manifest for #{repository}:#{tag}"
    else
      fail "Something went wrong while fetching manifest for #{repository}:#{tag}:" \
        "[#{res.code}] - #{res.body}"
    end
  end

  def get_request(path, request_auth_token=true)
    uri = URI.join(@base_url, path)
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{@token}" if @token

    res = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end

    if res.code.to_i == 401
      if request_auth_token
        request_auth_token(res)
        return get_request(path, false)
      else
        # this will never happen, request_auth_token will raise an exception
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
    req.basic_auth(@username, @password) if has_credentials?

    res = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end

    if res.code.to_i == 200
      @token = JSON.parse(res.body)['token']
    else
      @token = nil
      fail AuthorizationError, "Cannot obtain authorization token: #{res}"
    end
  end

  def parse_unhauthorized_response(res)
    auth_args = res.to_hash['www-authenticate'].first.split(',').each_with_object({}) do |i,h|
      key,val = i.split('=')
      h[key] = val.gsub('"', '')
    end

    unless has_credentials?
      fail CredentialsMissingError, "Registry #{@host} has authorization enabled, "\
        'user credentials not specified'
    end

    query_params = {
      'service' => auth_args['service'],
      'account' => @username
    }
    query_params['scope'] = auth_args['scope'] if auth_args.key?('scope')

    unless auth_args.key?('Bearer realm')
      fail(NoBearerRealmException, 'Cannot find bearer realm')
    end

    [auth_args['Bearer realm'], query_params]
  end
end
