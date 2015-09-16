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
      res = perform_request("_catalog")
      if res.code.to_i == 200
        catalog = JSON.parse(res.body)
        add_tags(catalog["repositories"])
      elsif res.code.to_i == 404
        handle_error res
      else
        raise "Something went wrong while fetching the catalog " \
          "Response: [#{res.code}] - #{res.body}"
      end
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

    private

    # Adds the available tags for each of the given repositories. If there is a
    # problem while fetching a repository's tag, it will return an empty array.
    # Otherwise it will return an array with the results as specified in the
    # documentation of the `catalog` method.
    def add_tags(repositories)
      return [] if repositories.nil?

      result = []
      repositories.each do |repo|
        res = perform_request("#{repo}/tags/list")
        return [] if res.code.to_i != 200
        result << JSON.parse(res.body)
      end
      result
    end
  end
end
