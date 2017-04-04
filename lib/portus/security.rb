require "portus/security_backends/clair"
require "portus/security_backends/dummy"
require "portus/security_backends/zypper"

module Portus
  class Security
    BACKENDS = [
      ::Portus::SecurityBackend::Clair,
      ::Portus::SecurityBackend::Dummy,
      ::Portus::SecurityBackend::Zypper
    ].freeze

    def initialize(repo, tag)
      @repo     = repo
      @tag      = tag
      @backends = []

      BACKENDS.each { |b| @backends << b.new(repo, tag) if b.enabled? }
    end

    # Returns a hash with the results from all the backends. The results are a
    # list of hashes.
    # TODO: document format
    def vulnerabilities
      # First get all the layers composing the given image.
      client = Registry.get.client
      manifest = client.manifest(@repo, @tag)

      params = {
        layers:       manifest.last["layers"].map { |l| l["digest"] },
        token:        client.token,
        registry_url: client.base_url
      }

      res = {}
      @backends.each do |b|
        name = b.class.name.to_s.demodulize.downcase.to_sym
        res[name] = b.vulnerabilities(params)
      end
      res
    end
  end
end
