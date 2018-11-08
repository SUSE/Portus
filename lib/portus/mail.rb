# frozen_string_literal: true

module Portus
  # Mail implements a set of utilities for mailing purposes.
  module Mail
    # ConfigurationError is raised when the given configuration has semantic
    # problems (e.g. malformed emails).
    class ConfigurationError < StandardError; end

    # Utils is a set of utility methods for mails.
    class Utils
      # config contains only the email configuration (i.e. APP_CONFIG["email"]
      # instead of APP_CONFIG directly).
      def initialize(config)
        @config = config
      end

      # check_email_configuration! raises a ::Portus::Mail::ConfigurationError
      # when any of the relevant emails is badly formatted.
      def check_email_configuration!
        check_email!("from")
        check_email!("reply_to") if @config["reply_to"].present?
      end

      # Returns a hash with the SMTP settings to be used by the mailer.
      def smtp_settings
        smtp = @config["smtp"]
        return unless smtp["enabled"]

        {
          address: smtp["address"],
          port:    smtp["port"],
          domain:  smtp["domain"]
        }.merge(ssl_settings).merge(authentication_settings)
      end

      protected

      # Returns the SMTP settings around SSL.
      def ssl_settings
        {
          enable_starttls_auto: @config["smtp"]["enable_starttls_auto"],
          openssl_verify_mode:  @config["smtp"]["openssl_verify_mode"]
        }.merge(ssl_tls).merge(ca)
      end

      # Returns a hash with either SSL or TLS enabled if the configuration
      # specifies it. It returns an empty hash when no SSL/TLS has been
      # configured.
      def ssl_tls
        if @config["smtp"]["ssl_tls"] == "ssl"
          { ssl: true }
        elsif @config["smtp"]["ssl_tls"] == "tls"
          { tls: true }
        else
          {}
        end
      end

      # Returns a hash with the `ca_path` and the `ca_file` options as specified
      # in the configuration.
      def ca
        {}.tap do |hsh|
          hsh[:ca_path] = @config["smtp"]["ca_path"] if @config["smtp"]["ca_path"]
          hsh[:ca_file] = @config["smtp"]["ca_file"] if @config["smtp"]["ca_file"]
        end
      end

      # Returns a hash with the authentication settings as specified in the
      # configuration. It returns an empty hash if the `user_name` field has
      # been left blank.
      def authentication_settings
        return {} if @config["smtp"]["user_name"].blank?

        {
          user_name:      @config["smtp"]["user_name"],
          password:       @config["smtp"]["password"],
          authentication: @config["smtp"]["authentication"]
        }
      end

      # check_email! raises an error when the given configuration key has a
      # badly formatted value.
      def check_email!(key)
        value = @config[key]
        return if value.match?(Devise.email_regexp)

        raise ConfigurationError,
              "Mail: bad config value for '#{key}'. '#{value}' is not a proper email..."
      end
    end
  end
end
