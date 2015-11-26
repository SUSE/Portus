module Portus
  # RegistryClient is a a layer between Portus and the Registry. Given a set of
  # credentials, it's able to call to any endpoint in the registry API. Moreover,
  # it also implements some handy methods on top of some of these endpoints (e.g.
  # the `manifest` method for the Manifest API endpoints).
  class RegistryClient
    include HttpHelpers

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
    # not.
    def reachable?
      res = perform_request("", "get", false)

      # If a 401 was retrieved, it means that at least the registry has been
      # contacted. In order to get a 200, this registry should be created and
      # an authorization requested. The former can be inconvenient, because we
      # might want to test whether the registry is reachable.
      !res.nil? && res.code.to_i == 401
    end

    # Retrieves the manifest for the required repository:tag. If everything goes
    # well, it will return a parsed response from the registry, otherwise it will
    # raise either ManifestNotFoundError or a RuntimeError.
    def manifest(repository, tag = "latest")
      res = perform_request("#{repository}/manifests/#{tag}")
      if res.code.to_i == 200
        JSON.parse(res.body)
      elsif res.code.to_i == 404
        handle_error res, repository: repository, tag: tag
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
      link = "_catalog?n=100"
      res = []

      # We fetch repositories in pages of 100 because of a bug in the registry.
      # See: https://github.com/docker/distribution/issues/1190.
      until link.empty?
        cat, link = catalog_page(link)
        res += cat["repositories"]
      end

      add_tags(res)
    end

    # Deletes a layer of the specified image. The layer is pointed by the digest
    # as given by the manifest of the image itself. Returns true if the request
    # was successful, otherwise it raises an exception.
    def delete(name, digest)
      res = perform_request("#{name}/blobs/#{digest}", "delete")
      if res.code.to_i == 202
        true
      elsif res.code.to_i == 404 || res.code.to_i == 405
        handle_error res, name: name, digest: digest
      else
        raise "Something went wrong while deleting blob: " \
          "[#{res.code}] - #{res.body}"
      end
    end

    protected

    # Fetches the next page in the catalog from the provided link. On success,
    # it will return an array of the items:
    #   - The parsed response body.
    #   - The link to the next page.
    # On error it will raise the proper exception.
    def catalog_page(link)
      res = perform_request(link)
      if res.code.to_i == 200
        [JSON.parse(res.body), fetch_link(res["link"])]
      elsif res.code.to_i == 404
        handle_error res
      else
        raise "Something went wrong while fetching the catalog " \
          "Response: [#{res.code}] - #{res.body}"
      end
    end

    # Fetch the link to the next catalog page from the given response.
    def fetch_link(header)
      return "" if header.blank?
      link = header.split(";")[0]
      link.strip[1, link.size - 2]
    end

    # Adds the available tags for each of the given repositories. If there is a
    # problem while fetching a repository's tag, it will return an empty array.
    # Otherwise it will return an array with the results as specified in the
    # documentation of the `catalog` method.
    def add_tags(repositories)
      return [] if repositories.nil?

      result = []
      repositories.each do |repo|
        res = perform_request("#{repo}/tags/list")
        result << JSON.parse(res.body) if res.code.to_i == 200
      end
      result
    end
  end
end
