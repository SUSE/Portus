# frozen_string_literal: true

module Portus
  # RegistryClient is a a layer between Portus and the Registry. Given a set of
  # credentials, it's able to call to any endpoint in the registry API. Moreover,
  # it also implements some handy methods on top of some of these endpoints (e.g.
  # the `manifest` method for the Manifest API endpoints).
  # rubocop:disable Metrics/ClassLength
  class RegistryClient
    attr_accessor :token
    attr_reader   :base_url

    include HttpHelpers

    # ManifestError is the exception that it will be raised when a manifest
    # fetch has given a bad HTTP status code.
    class ManifestError < StandardError; end

    # UnsupportedMediaType is the exception to be raised when the target
    # mediaType given by the Registry is unsupported.
    class UnsupportedMediaType < StandardError; end

    # Exception being raised when we get an error from the Registry API that we
    # don't know how to handle.
    class RegistryError < StandardError; end

    # Initialize the client by setting up a hostname and the user. Note that if
    # no user was given, the "portus" special user is assumed.
    def initialize(host, use_ssl = false, username = nil, password = nil)
      @host     = host
      @use_ssl  = use_ssl
      @base_url = "http#{"s" if @use_ssl}://#{@host}/v2/"
      @username = username || "portus"
      @password = password || Rails.application.secrets.portus_password
    end

    # Returns whether the registry is reachable with the given credentials or
    # not. This might raise a RequestError on failure.
    def reachable?
      res = safe_request("/v2/", "get", false)

      # The 'Docker-Distribution-Api-Version' header indicates that we are connected to a
      # Docker Registry endpoint.
      # 401 means that the registry requires authentication
      # In order to get a 200, this registry should be created and
      # an authorization requested. The former can be inconvenient, because we
      # might want to test whether the registry is reachable.
      !res.nil? && res.header.key?("Docker-Distribution-Api-Version") &&
        (res.code.to_i == 401 || res.code.to_i == 200)
    end

    # Calls the `/:repository/manifests/:tag` endpoint from the registry. It
    # returns an OpenStruct object with the following attributes:
    #
    #   - id:     The image ID (without the "sha256:" prefix)
    #   - digest: The manifest digest
    #   - size:   The tag size
    #   - mf:     The manifest itself as a ruby hash
    #
    # Three different exceptions might be raised:
    #
    #   - ::Portus::RequestError: there was a request error with the registry
    #     (e.g. a timeout).
    #   - ::Portus::Errors::NotFoundError: the given manifest was not found.
    #   - ::Portus::RegistryClient::ManifestError: there was an unknown problem
    #     with the manifest.
    def manifest(repository, tag = "latest")
      res = safe_request("#{repository}/manifests/#{tag}", "get")

      if res.code.to_i == 200
        mf = JSON.parse(res.body)
        id = mf.try(:[], "config").try(:[], "digest")
        id = id.split(":").last if id.is_a? String
        digest = res["Docker-Content-Digest"]
        size = calculate_tag_size(mf)
        OpenStruct.new(id: id, digest: digest, size: size, mf: mf)
      elsif res.code.to_i == 404
        handle_error res, repository: repository, tag: tag
      else
        raise ::Portus::RegistryClient::ManifestError,
              "Something went wrong while fetching manifest for " \
              "#{repository}:#{tag}:[#{res.code}] - #{res.body}"
      end
    end

    # Returns the total compressed size of a tag and its layers in bytes.
    #
    # The json navigation is based on Image Manifest Version 2, Schema 2 that
    # is available at https://docs.docker.com/registry/spec/manifest-v2-2/
    def calculate_tag_size(manifest)
      layers = manifest["layers"]
      size = manifest["config"]["size"]
      layers.each { |layer| size += layer["size"] } if layers.present?

      size
    end

    # Fetches all the repositories available in the registry, with all their
    # corresponding tags. If something goes wrong while fetching the repos from
    # the catalog (e.g. authorization error), it will raise an exception.
    #
    # Returns an array of hashes where each hash contains a `name` and a `tags`
    # field. The given repository name is fully qualified and the `tags` field
    # simply contains an array of strings for each tag.
    #
    # The list of tags for each repository is taken by calling `#tags`, and it
    # handles the exceptions that might be raised. If an exception was raised
    # when fetching the tags (e.g. a timeout), then it will set the `tags` field
    # of the currently evaluated repository to nil. This is done this way
    # because setting an empty value would be ambiguous, and leaving exception
    # handling to upper layers might be confusing.
    #
    # Three different exceptions might be raised:
    #
    #   - ::Portus::RequestError: there was a request error with the registry
    #     (e.g. a timeout).
    #   - ::Portus::Errors::NotFoundError: the given manifest was not found.
    #   - ::Portus::RegistryClient::RegistryError: there was an unknown problem
    #     with the request.
    def catalog
      res = paged_response("_catalog", "repositories")
      add_tags(res)
    end

    # Returns an array containing the list of tags. If something goes wrong,
    # then it raises an exception.
    #
    # Three different exceptions might be raised:
    #
    #   - ::Portus::RequestError: there was a request error with the registry
    #     (e.g. a timeout).
    #   - ::Portus::Errors::NotFoundError: the given manifest was not found.
    #   - ::Portus::RegistryClient::RegistryError: there was an unknown problem
    #     with the request.
    def tags(repository)
      paged_response("#{repository}/tags/list", "tags")
    end

    # Deletes a blob/manifest of the specified image. Returns true if the
    # request was successful, otherwise it raises an exception. Three different
    # exceptions might be raised:
    #
    #   - ::Portus::RequestError: there was a request error with the registry
    #     (e.g. a timeout).
    #   - ::Portus::Errors::NotFoundError: the given manifest was not found.
    #   - ::Portus::RegistryClient::RegistryError: there was an unknown problem
    #     with the request.
    def delete(name, digest, object = "blobs")
      res = safe_request("#{name}/#{object}/#{digest}", "delete")
      if res.code.to_i == 202
        true
      elsif res.code.to_i == 404 || res.code.to_i == 405
        handle_error res, name: name, digest: digest
      else
        raise ::Portus::RegistryClient::RegistryError,
              "Something went wrong while deleting blob: " \
              "[#{res.code}] - #{res.body}"
      end
    end

    protected

    # Returns all the items that could be extracted from the given link that are
    # indexed by the given field in a successful response.
    #
    # If anything goes wrong, it raises an exception: ::Portus::RequestError,
    # ::Portus::Errors::NotFoundError or
    # ::Portus::RegistryClient::RegistryError.
    def paged_response(link, field)
      res = []
      link += "?n=#{APP_CONFIG["registry"]["catalog_page"]["value"]}"

      until link.empty?
        page, link = get_page(link)
        next unless page[field]

        res += page[field]
      end
      res
    end

    # Fetches the next page from the provided link. On success, it will return
    # an array of the items:
    #   - The parsed response body.
    #   - The link to the next page.
    #
    # On error it will raise the proper exception: ::Portus::RequestError,
    # ::Portus::Errors::NotFoundError or
    # ::Portus::RegistryClient::RegistryError.
    def get_page(link)
      res = safe_request(link)
      if res.code.to_i == 200
        [JSON.parse(res.body), fetch_link(res["link"])]
      elsif res.code.to_i == 404
        handle_error res
      else
        raise ::Portus::RegistryClient::RegistryError,
              "Something went wrong while fetching the catalog " \
              "Response: [#{res.code}] - #{res.body}"
      end
    end

    # Fetch the link to the next catalog page from the given response.
    def fetch_link(header)
      return "" if header.blank?

      link = header.split(";")[0]
      link.strip[1, link.size - 2]
    end

    # Adds the available tags for each of the given repositories. If the given
    # repository object is nil, then it returns an empty array.
    #
    # The returned object on success (or partial success) is explained in the
    # `#catalog` method.
    def add_tags(repositories)
      return [] if repositories.nil?

      result = []
      repositories.each do |repo|
        ts = nil

        begin
          ts = tags(repo)
        rescue ::Portus::RequestError, ::Portus::Errors::NotFoundError,
               ::Portus::RegistryClient::RegistryError => e
          Rails.logger.debug "Could not get tags for repo: #{repo}: #{e.message}."
        end

        result << { "name" => repo, "tags" => ts }
      end
      result
    end
  end
  # rubocop:enable Metrics/ClassLength
end
