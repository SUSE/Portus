# frozen_string_literal: true

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

    # Returns true if there is backends that work available, false otherwise.
    def available?
      @backends.present?
    end

    # Returns true if security scanning is enabled, false otherwise.
    def self.enabled?
      ::Portus::Security::BACKENDS.any? do |b|
        APP_CONFIG["security"][b.config_key]["server"].present?
      end
    end

    # Returns a hash with the results from all the backends. The results are a
    # list of hashes. If security vulnerability checking is not enabled, then
    # nil is returned.
    def vulnerabilities
      return unless available?

      # First get all the layers composing the given image.
      client = Registry.get.client
      layers = fetch_layers(client)
      return unless layers

      params = {
        layers:       layers.map { |l| l["digest"] },
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

    # Returns an array with the layers as given in the manifest. If an error
    # occured then nil will be returned and the error will be logged.
    def fetch_layers(rc)
      manifest = rc.manifest(@repo, @tag)
      manifest.mf["layers"]
    rescue ::Portus::RequestError, ::Portus::Errors::NotFoundError,
           ::Portus::RegistryClient::ManifestError => e
      Rails.logger.info e.to_s
      nil
    end
  end
end
