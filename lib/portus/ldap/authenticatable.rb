# frozen_string_literal: true

require "net/ldap"
require "devise/strategies/authenticatable"

require "portus/ldap/configuration"
require "portus/ldap/connection"
require "portus/ldap/errors"
require "portus/ldap/login"

module Portus
  module LDAP
    # Authenticatable implements Devise's authenticatable for LDAP servers. This
    # class will fallback to other strategies if LDAP support is not enabled.
    #
    # If we can bind to the server with the given credentials, we assume that
    # the authentication was successful. In this case, if this is the first time
    # that this user enters Portus, it will be saved inside of Portus' DB. There
    # are some issues while doing this:
    #
    #   1. The 'email' is not provided in a standard way: some LDAP servers may
    #      provide it, some others won't. Portus tries to guess the email by
    #      following the "ldap.guess_email" configurable value. If no email could
    #      be guessed, the controller layer should handle this.
    #   2. The 'password' is stored in the DB but it's not really used. This is
    #      because the DB requires the password to not be blank, but in order to
    #      authenticate we always want to check with the LDAP server.
    #
    # This class is only useful if LDAP is enabled in the `config/config.yml`
    # file. Take a look at this file in order to read more on the different
    # configurable values.
    class Authenticatable < Devise::Strategies::Authenticatable
      include ::Portus::LDAP::Adapter
      include ::Portus::LDAP::Connection
      include ::Portus::LDAP::Errors
      include ::Portus::LDAP::Login

      # Re-implemented from Devise::Strategies::Authenticatable to authenticate
      # the user.
      def authenticate!
        fill_user_params!

        cfg = ::Portus::LDAP::Configuration.new(params)
        if cfg.enabled?
          connection = initialized_adapter
          entry, admin = bind_as(connection, cfg)
          portus_login!(connection, cfg, admin) if entry
        elsif cfg.soft?
          # rubocop:disable Style/SignalException
          fail cfg.reason_message
          # rubocop:enable Style/SignalException
        else
          fail! cfg.reason_message
        end
      rescue ::Portus::LDAP::Error, Net::LDAP::Error => e
        logged_failure!(e.message)
      end

      protected

      # If the `:user` HTTP parameter is not set, try to fetch it from the HTTP
      # Basic Authentication header. If successful, it will update the `:user`
      # HTTP parameter accordingly.
      def fill_user_params!
        return if request.env.nil? || !params[:user].nil?

        # Try to get the username and the password through HTTP Basic
        # Authentication, since the Docker CLI client authenticates this way.
        user, pass = ActionController::HttpAuthentication::Basic.user_name_and_password(request)
        params[:user] = { username: user, password: pass }
      end
    end
  end
end
