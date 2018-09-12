# frozen_string_literal: true

require "portus/mail"

unless Rails.env.test?
  # In some weird cases APP_CONFIG is not even there. In these cases, just go
  # back to sendmail.
  if defined?(APP_CONFIG)
    # Check that emails have the proper format.
    mail = ::Portus::Mail::Utils.new(APP_CONFIG["email"])
    mail.check_email_configuration!

    # Fetch SMTP settings. On success, it will set SMTP as the delivery method,
    # otherwise we fall back to sendmail.
    settings = mail.smtp_settings
    if settings
      Portus::Application.config.action_mailer.delivery_method = :smtp
      ActionMailer::Base.smtp_settings = settings
    else
      Portus::Application.config.action_mailer.delivery_method = :sendmail
    end
  else
    Portus::Application.config.action_mailer.delivery_method = :sendmail
  end
end
