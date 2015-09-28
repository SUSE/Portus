# If SMTP was set, then use it as the delivery method and configure it with the
# given config.
if defined?(APP_CONFIG) && APP_CONFIG["email"]["smtp"]["enabled"]
  Portus::Application.config.action_mailer.delivery_method = :smtp

  smtp = APP_CONFIG["email"]["smtp"]
  ActionMailer::Base.smtp_settings = {
    address:              smtp["address"],
    port:                 smtp["port"],
    user_name:            smtp["user_name"],
    password:             smtp["password"],
    domain:               smtp["domain"],
    authentication:       :login,
    enable_starttls_auto: true
  }
end
