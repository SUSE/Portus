require "net/ldap"
require "devise/strategies/authenticatable"

module Portus
  # Portus::LDAP implements Devise's authenticatable for LDAP servers. This
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
  class LDAP < Devise::Strategies::Authenticatable
    # Re-implemented from Devise::Strategies::Authenticatable to authenticate
    # the user.
    def authenticate!
      @ldap = load_configuration

      # If LDAP is enabled try to authenticate through the LDAP server.
      # Otherwise we fall back to the next strategy.
      if @ldap
        # Try to bind to the LDAP server. If there's any failure, the
        # authentication process will fail without going to the any other
        # strategy.
        if @ldap.bind_as(bind_options)
          user = find_or_create_user!
          user.valid? ? success!(user) : fail!(user.errors.full_messages.join(","))
        else
          fail!(:ldap_bind_failed)
        end
      else
        # rubocop:disable Style/SignalException
        fail(:ldap_failed)
        # rubocop:enable Style/SignalException
      end
    end

    # Returns true if LDAP has been enabled in the application, false
    # otherwise.
    def self.enabled?
      APP_CONFIG.enabled?("ldap")
    end

    protected

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

    # Returns true if authentication has been enabled in configuration, false
    # otherwise.
    def authentication?
      APP_CONFIG["ldap"]["authentication"] && APP_CONFIG["ldap"]["authentication"]["enabled"]
    end

    def adapter_options
      cfg = APP_CONFIG["ldap"]
      {
        host:       cfg["hostname"],
        port:       cfg["port"],
        encryption: encryption(cfg)
      }.tap do |options|
        options.merge!(auth_options) if authentication?
      end
    end

    # Loads the configuration and authenticates the current user.
    def load_configuration
      # Note that the Portus user needs to authenticate through the DB.
      return nil if !::Portus::LDAP.enabled? || params[:account] == "portus"

      fill_user_params!
      return nil if params[:user].nil?

      adapter.new(adapter_options)
    end

    # Returns the encryption method to be used. Invalid encryption methods will
    # be mapped to "plain".
    def encryption(config)
      case config["method"]
      when "starttls"
        :start_tls
      when "simple_tls"
        :simple_tls
      end
    end

    # Returns the class to be used for LDAP support. Mainly declared this way
    # so tests can mock this away. This can also be useful if we decide to jump
    # on another gem for LDAP support.
    def adapter
      Net::LDAP
    end

    # Returns the option hash to be used in order to authenticate the user in
    # the LDAP server.
    def bind_options
      search_options.merge(password: password)
    end

    # Returns the hash to be used in order to search for a user in the LDAP
    # server.
    def search_options
      {}.tap do |opts|
        uid = APP_CONFIG["ldap"]["uid"]
        opts[:filter] = "(#{uid}=#{username})"
        opts[:base]   = APP_CONFIG["ldap"]["base"] unless APP_CONFIG["ldap"]["base"].empty?
      end
    end

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

    # Retrieve the given user as an LDAP user. If it doesn't exist, create it
    # with the parameters given in the form.
    def find_or_create_user!
      user = User.find_by(ldap_name: username)

      # The user does not exist in Portus yet, let's create it. If it does
      # not match a valid username, it will be transformed into a proper one.
      unless user
        ldap_name = username.dup
        if User::USERNAME_FORMAT.match(ldap_name)
          name = ldap_name
        else
          name = ldap_name.gsub(/[^#{User::USERNAME_CHARS}]/, "")
        end

        # This is to check that no clashes occur. This is quite improbable to
        # happen, since it would mean that the name contains characters like
        # "$", "!", etc. We also check that the name is longer than 4
        # (requirement from Docker).
        if name.length < 4 || User.exists?(username: name)
          name = generate_random_name(name)
        end

        user = User.create(
          username:  name,
          email:     guess_email,
          password:  password,
          admin:     !User.not_portus.any?,
          ldap_name: ldap_name
        )
      end
      user
    end

    # It generates a new name that doesn't clash with any of the existing ones.
    def generate_random_name(name)
      # Even if the name has just one character, adding a number of at least
      # three digits would make the name valid.
      offset = name.length < 4 ? 100 : 0

      10.times do
        nn = "#{name}#{Random.rand(offset + 101)}"
        return nn unless User.exists?(username: nn)
      end

      # We have not been able to generate a new name, let's raise an exception.
      fail!(:random_generation_failed)
    end

    # If the "ldap.guess_email" option is enabled, try to guess the email for
    # the user as specified in the configuration. Returns an nil if nothing
    # could be guessed.
    def guess_email
      cfg = APP_CONFIG["ldap"]["guess_email"]
      return nil if cfg.nil? || !cfg["enabled"]

      record = @ldap.search(search_options)
      return nil if record.size != 1
      record = record.first

      cfg["attr"].empty? ? guess_from_dn(record["dn"]) : guess_from_attr(record, cfg["attr"])
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
    def guess_from_dn(dn)
      return nil if dn.nil? || dn.size != 1

      dc = []
      dn.first.split(",").each do |value|
        kv = value.split("=")
        dc << kv.last if kv.first == "dc"
      end
      return nil if dc.empty?

      "#{username}@#{dc.join(".")}"
    end

    ##
    # Parameters.

    def username
      params[:user][:username]
    end

    def password
      params[:user][:password]
    end
  end
end
