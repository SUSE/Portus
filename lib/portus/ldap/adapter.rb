# frozen_string_literal: true

module Portus
  module LDAP
    # Adapter implements a set of methods relevant for the LDAP adapter. That
    # is, it contains a method that returns the adapter to be used, and another
    # one containing the options to be used within this adapter.
    module Adapter
      # Returns the class to be used for LDAP support. Mainly declared this way
      # so tests can mock this away. This can also be useful if we decide to jump
      # on another gem for LDAP support.
      def adapter
        Net::LDAP
      end

      # Returns the options to be passed to the LDAP adapter. This contains a
      # hash with elements for binding to the given LDAP server, plus some
      # optional authentication and encryption options.
      def adapter_options
        cfg = APP_CONFIG["ldap"]
        {
          host:               cfg["hostname"],
          port:               cfg["port"],
          connection_timeout: cfg["timeout"],
          encryption:         encryption(cfg)
        }.tap do |options|
          options.merge!(auth_options) if authentication?
        end
      end

      # Returns an instance of the LDAP adapter initialized with the evaluated
      # connection options.
      def initialized_adapter
        adapter.new(adapter_options)
      end

      protected

      # Returns true if authentication has been enabled in configuration, false
      # otherwise.
      def authentication?
        APP_CONFIG["ldap"]["authentication"] && APP_CONFIG["ldap"]["authentication"]["enabled"]
      end

      # Returns auth options according to configuration.
      def auth_options
        cfg = APP_CONFIG["ldap"]
        {
          auth: {
            username: cfg["authentication"]["bind_dn"],
            password: cfg["authentication"]["password"],
            method:   :simple
          }
        }
      end

      # Returns the encryption hash to be used. If no encryption is being used,
      # then nil is returned.
      def encryption(config)
        method = encryption_method(config)
        return if method.blank?

        {
          method:      method,
          tls_options: encryption_options(config)
        }
      end

      # Returns the encryption method as a symbol or nil if none was provided.
      def encryption_method(config)
        method = config["encryption"]["method"]
        case method.to_s
        when "start_tls", "simple_tls"
          method.to_sym
        when "starttls"
          :start_tls
        end
      end

      # Returns the encryption options to be used. If none was specified, then the
      # default parameters will be returned (default CA from the host).
      def encryption_options(config)
        options = config["encryption"]["options"]
        return OpenSSL::SSL::SSLContext::DEFAULT_PARAMS if options.blank? ||
                                                           options["ca_file"].blank?

        { ca_file: options["ca_file"] }.tap do |opt|
          opt[:ssl_version] = options["ssl_version"] if options["ssl_version"].present?
        end
      end
    end
  end
end
