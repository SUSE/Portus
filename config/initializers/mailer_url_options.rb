# If you're on staging/production, then you must be using SSL. Otherwise, if
# you're on development mode and you have set your own FQDN, then we assume
# that SSL is in place too. Otherwise, SSL is not setup.
protocol = if !Rails.env.development? || !ENV["PORTUS_USE_SSL"].nil?
  "https://"
else
  "http://"
end

host = APP_CONFIG["machine_fqdn"]["value"]
ActionMailer::Base.default_url_options[:host]     = host
ActionMailer::Base.default_url_options[:protocol] = protocol

Rails.logger.tagged("Mailer config") do
  Rails.logger.info "Host:     #{host}"
  Rails.logger.info "Protocol: #{protocol}"
end
