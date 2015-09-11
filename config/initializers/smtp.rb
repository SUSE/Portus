# Fetch the value of the given "PORTUS_SMTP_*" environment variable. If it's
# not set, then it will raise an exception containing a descriptive message.
def safe_env(name)
  name = "PORTUS_SMTP_#{name}".upcase
  unless ENV[name]
    raise StandardError, "SMTP is enabled but the environment variable '#{name}' has not been set!"
  end
  ENV[name]
end

if Rails.env.production? && APP_CONFIG["email"]["smtp"]
  ActionMailer::Base.smtp_settings = {
    address:              safe_env("address"),
    port:                 safe_env("port"),
    user_name:            safe_env("username"),
    password:             safe_env("password"),
    domain:               safe_env("domain"),
    authentication:       :login,
    enable_starttls_auto: true
  }
end
