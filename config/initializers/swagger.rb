# frozen_string_literal: true

unless Rails.env.production?
  protocol = ::APP_CONFIG.enabled?("check_ssl_usage") ? "https://" : "http://"

  GrapeSwaggerRails.options.url      = "/api/swagger_doc.json"
  GrapeSwaggerRails.options.app_url  = "#{protocol}#{APP_CONFIG["machine_fqdn"]["value"]}"
end
