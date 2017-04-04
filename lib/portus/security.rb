require "portus/security_backends/clair"
require "portus/security_backends/zypper"

module Portus
  class Security
    BACKENDS = [
      ::Portus::SecurityBackend::Clair,
      ::Portus::SecurityBackend::Zypper
    ].freeze

    def initialize(repo, tag)
      @repo     = repo
      @tag      = tag
      @backends = []

      BACKENDS.each { |b| @backends << b.new(repo, tag) if b.enabled? }
    end

    # Returns a list with all the vulnerabilities that have been discovered for
    # the given repository and tag.
    def vulnerabilities
      # First get all the layers composing the given image.
      client = Registry.get.client
      manifest = client.manifest(@repo, @tag)
      layers = manifest.last["layers"].map { |l| l["digest"] }

      # And now let's pass those layers to each driver.
      # TODO: merge results
      @backends.first.vulnerabilities(layers, client.token, client.base_url)
    end
  end
end
