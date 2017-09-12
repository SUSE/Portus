module Portusctl
  module Options
    module Mailer
      def self.included(thor)
        thor.class_eval do
          option "email-from",
                 desc:    "MAIL: sender address",
                 default: "portus@#{HOSTNAME}"
          option "email-name", desc: "MAIL: sender name", default: "Portus"
          option "email-reply-to",
                 desc:    "MAIL: reply to address",
                 default: "no-reply@#{HOSTNAME}"
          option "email-smtp-enable",
                 desc:    "MAIL: use SMTP as the delivery method",
                 type:    :boolean,
                 default: false
          option "email-smtp-address",
                 desc:    "MAIL: the address to the SMTP server",
                 default: "smtp.example.com"
          option "email-smtp-port", desc: "MAIL: SMTP server port", default: "587"
          option "email-smtp-username",
                 desc:    "MAIL: the user name to be used for logging in the SMTP server",
                 default: "username@example.com"
          option "email-smtp-password",
                 desc:    "MAIL: the password to be used for logging in the SMTP server",
                 default: "password"
          option "email-smtp-domain",
                 desc:    "MAIL: the domain of the SMTP server",
                 default: "example.com"
        end
      end
    end
  end
end
