unless Rails.env.production?
  protocol = ENV["PORTUS_CHECK_SSL_USAGE_ENABLED"] ? "https://" : "http://"

  GrapeSwaggerRails.options.url      = "/api/swagger_doc.json"
  GrapeSwaggerRails.options.app_url  = "#{protocol}#{APP_CONFIG["machine_fqdn"]["value"]}"
end
