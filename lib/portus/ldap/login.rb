# frozen_string_literal: true

module Portus
  module LDAP
    # Login contains a set of methods for logging the given user into Portus. At
    # this point, we assume that LDAP binding worked, and so we want to
    # register/login this user into Portus.
    module Login
      # Fetch the user assumed from `cfg` and log it. If the user does not
      # exist yet, it will be created and the `session[:first_login]` value will
      # be set to true, so the sessions controller can act accordingly.
      def portus_login!(connection, cfg, admin)
        user, created = find_or_create_user!(connection, cfg, admin)
        if user.valid?
          session[:first_login] = true if created
          success!(user)
        else
          fail!(user.errors.full_messages.join(","))
        end
      end

      protected

      # Retrieve the given user as an LDAP user. If it doesn't exist, create it
      # with the parameters given in `cfg`. Returns two objects: the user object
      # and a boolean set to true if the returned user was just created.
      def find_or_create_user!(connection, cfg, admin)
        user = User.find_by(username: cfg.username)
        created = false

        # The user does not exist in Portus yet, let's create it.
        unless user
          em = guess_email(connection, cfg)
          em = nil if em && User.exists?(email: em)

          user, created = User.create_without_password(
            username: cfg.username,
            email:    em,
            admin:    admin || User.not_portus.where(bot: false).none?
          )
        end
        [user, created]
      end

      # If the "ldap.guess_email" option is enabled, try to guess the email for
      # the user as specified in the configuration. Returns nil if nothing could
      # be guessed.
      def guess_email(connection, configuration)
        cfg = APP_CONFIG["ldap"]["guess_email"]
        return if cfg.nil? || !cfg["enabled"]

        record = search_admin_or_user(connection, configuration)
        return if record&.size != 1

        record = record.first

        if cfg["attr"].empty?
          guess_from_dn(record["dn"], configuration.username)
        else
          guess_from_attr(record, cfg["attr"])
        end
      rescue ::Net::LDAP::Error => e
        Rails.logger.tagged(:ldap) { Rails.logger.warn "Connection error: #{e.message}" }
        nil
      end

      # Guess the email from the given attribute. Note that if multiple records
      # are fetched, then only the first one will be returned. It might return
      # nil if no email could be guessed.
      def guess_from_attr(record, attr)
        email = record[attr]
        email.is_a?(Array) ? email.first : email
      end

      # Guesses the email being fetching "dc" components of the given
      # distinguished name. If the email could not be guessed, then it returns
      # nil.
      def guess_from_dn(dn, username)
        if dn.nil? || dn.size != 1
          Rails.logger.tagged(:ldap) { Rails.logger.debug "Empty DN given, skipping..." }
          return nil
        end

        dc = []
        dn.first.split(",").each do |value|
          kv = value.split("=")
          dc << kv.last if kv.first == "dc"
        end

        if dc.empty?
          Rails.logger.tagged(:ldap) do
            Rails.logger.debug "Could not extract domain from dn '#{dn.first}'"
          end
          nil
        else
          "#{username}@#{dc.join(".")}"
        end
      end
    end
  end
end
