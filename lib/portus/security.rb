require "portus/security_backends/clair"
require "portus/security_backends/dummy"
require "portus/security_backends/zypper"

module Portus
  # Security offers methods that are useful for fetching vulnerabilities for the
  # given repositories & tags.
  class Security
    # Supported backends.
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

    # Returns true if security scanning is enabled, false otherwise.
    def enabled?
      !@backends.empty?
    end

    # Returns a hash with the results from all the backends. The results are a
    # list of hashes. If security vulnerability checking is not enabled, then
    # nil is returned.
    def vulnerabilities
      return unless enabled?

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
