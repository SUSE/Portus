# frozen_string_literal: true

# :nocov:

module ::Portus
  # Test defines constants which are used in multiple places regarding
  # integration tests.
  class Test
    LOCAL_IMAGE        = "opensuse/portus:development"
    HEAD_IMAGE         = "opensuse/portus:head"
    DEVELOPMENT_MATRIX = {
      background: LOCAL_IMAGE,
      db:         "library/mariadb:10.0.23",
      clair:      "quay.io/coreos/clair:v2.0.1",
      ldap:       "osixia/openldap:1.2.0",
      portus:     LOCAL_IMAGE,
      postgres:   "library/postgres:10-alpine",
      registry:   "library/registry:2.7.1"
    }.freeze

    # Returns true if the given image is allowed to fail in an integration
    # test. Note that this image can be a string or a hash (with an element
    # named :portus).
    def self.allow_failure?(image)
      return HEAD_IMAGE == image if image.is_a? String

      image[:portus] == HEAD_IMAGE
    end
  end
end
