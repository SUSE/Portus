# frozen_string_literal: true

unless Rails.env.production?
  protocol = ::APP_CONFIG.enabled?("check_ssl_usage") ? "https://" : "http://"
  port = if ENV["PORTUS_PUMA_HOST"]
           val = ENV["PORTUS_PUMA_HOST"].split(":")
           ":#{val.last}" if val.size == 2
         end

  GrapeSwaggerRails.options.url     = "/api/openapi-spec"
  GrapeSwaggerRails.options.app_url = "#{protocol}#{APP_CONFIG["machine_fqdn"]["value"]}#{port}"
end
