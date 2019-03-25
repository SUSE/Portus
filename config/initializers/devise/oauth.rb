# frozen_string_literal: true

# In order to provide a new backend, you have to:
#
# 1. Add support for it on the `lib` directory or add the gem on the Gemfile.
# 2. Add a method called "#{backend}_fetch_options" on this file that returns
#    the specific options to be passed to omniauth for this backend.
# 3. Add it on the hash from `configure_oauth!` by also specifying user id and
#    secret if needed.

#
# Backend-specific methods.
#

def google_oauth2_fetch_options
  options = APP_CONFIG["oauth"]["google_oauth2"]["options"].reject { |_k, v| v.blank? }
  options[:skip_jwt] = true
  options
end

def open_id_fetch_options
  require "openid/store/filesystem"

  options = { store: OpenID::Store::Filesystem.new("/tmp") }

  if APP_CONFIG["oauth"]["open_id"]["identifier"].present?
    options[:identifier] = APP_CONFIG["oauth"]["open_id"]["identifier"]
  end
  options
end

def openid_connect_fetch_options
  {
    name:           :openid_connect,
    scope:          %i[openid email profile address],
    response_type:  :code,
    discovery:      true,
    issuer:         APP_CONFIG["oauth"]["openid_connect"]["issuer"],
    client_options: {
      identifier: APP_CONFIG["oauth"]["openid_connect"]["identifier"],
      secret:     APP_CONFIG["oauth"]["openid_connect"]["secret"]
    },
    setup:          lambda { |env|
      # Set client_options.redirect_uri to <protocol>://<host>/users/auth/openid_connect/callback
      strategy = env["omniauth.strategy"]

      if strategy.request_path == "/users/auth/openid_connect"
        redirect_uri = strategy.full_host + strategy.script_name + strategy.callback_path
        strategy.options["client_options"]["redirect_uri"] = redirect_uri
      end
    }
  }
end

def github_fetch_options
  server = APP_CONFIG["oauth"]["github"]["server"].presence || "github.com"

  {
    scope: "read:user,user:email,read:org",
    client_options: {
      site: "https://api.#{server}",
      authorize_url: "https://#{server}/login/oauth/authorize",
      token_url: "https://#{server}/login/oauth/access_token",
    }
  }

end

def gitlab_fetch_options
  site = APP_CONFIG["oauth"]["gitlab"]["server"].presence || "https://gitlab.com"

  { client_options: { site: site } }
end

def bitbucket_fetch_options
  require "omni_auth/strategies/bitbucket"

  APP_CONFIG["oauth"]["bitbucket"]["options"].reject { |_k, v| v.blank? }
end

#
# General methods.
#

# configure_backend! calls the specific `_fetch_options` method for the given
# backend and configures omniauth with the given credentials.
def configure_backend!(config, backend, id = nil, secret = nil)
  return unless Rails.env.test? || APP_CONFIG.enabled?("oauth.#{backend}")

  options = send("#{backend}_fetch_options")

  if id
    config.omniauth backend, id, secret, options
  else
    config.omniauth backend, options
  end
end

# configure_oauth! will setup the initialization code for each backend.
def configure_oauth!(config)
  [
    { backend: :google_oauth2, id: "id", secret: "secret" },
    { backend: :open_id },
    { backend: :openid_connect },
    { backend: :github, id: "client_id", secret: "client_secret" },
    { backend: :gitlab, id: "application_id", secret: "secret" },
    { backend: :bitbucket, id: "key", secret: "secret" }
  ].each do |b|
    if b[:id]
      id = APP_CONFIG["oauth"][b[:backend].to_s][b[:id]]
      secret = APP_CONFIG["oauth"][b[:backend].to_s][b[:secret]]
    else
      id = nil
      secret = nil
    end

    configure_backend!(config, b[:backend], id, secret)
  end
end
