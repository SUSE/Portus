# If you're on staging/production, then you must be using SSL. Otherwise, if
# you're on development mode and you have set your own FQDN, then we assume
# that SSL is in place too. Otherwise, SSL is not setup.
if !Rails.env.development? || !ENV["PORTUS_MACHINE_FQDN"].empty?
  protocol = "https://"
else
  protocol = "http://"
end

host = Rails.application.secrets.machine_fqdn
ActionMailer::Base.default_url_options[:host]     = host
ActionMailer::Base.default_url_options[:protocol] = protocol

Rails.logger.tagged("Mailer config") do
  Rails.logger.info "Host:     #{host}"
  Rails.logger.info "Protocol: #{protocol}"
end
