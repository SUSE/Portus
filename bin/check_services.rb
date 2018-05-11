# frozen_string_literal: true

##
# TODO: this should be re-purposed once we support health for LDAP

require "net/ldap"

puts case Portus::DB.ping
     when :ready
       "DB_READY"
     when :empty
       "DB_EMPTY"
     when :missing
       "DB_MISSING"
     when :down
       "DB_DOWN"
     else
       "DB_UNKNOWN"
     end

params = { host: APP_CONFIG["ldap"]["hostname"], port: APP_CONFIG["ldap"]["port"] }

# Fill authentication details.
if APP_CONFIG.enabled?("ldap.authentication")
  params[:auth] = {
    method:   :simple,
    username: APP_CONFIG["ldap"]["authentication"]["bind_dn"],
    password: APP_CONFIG["ldap"]["authentication"]["password"]
  }
end

# Fill TLS options with the given env. variables or assume defaults.
if APP_CONFIG["ldap"]["encryption"]["method"].present?
  params[:encryption] = { method: APP_CONFIG["ldap"]["encryption"]["method"].to_sym }

  if APP_CONFIG["ldap"]["encryption"]["options"]["ca_file"].present?
    params[:encryption][:tls_options] = {
      ca_file:     APP_CONFIG["ldap"]["encryption"]["options"]["ca_file"],
      ssl_version: APP_CONFIG["ldap"]["encryption"]["options"]["ssl_version"]
    }
  else
    params[:encryption][:tls_options] = OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
  end
end

if APP_CONFIG.disabled?("ldap")
  puts "LDAP_DISABLED"
else
  ldap = Net::LDAP.new(params)
  begin
    if ldap.bind
      puts "LDAP_OK"
    else
      puts "LDAP_FAIL"
    end
  rescue Net::LDAP::Error
    puts "LDAP_FAIL"
  end
end
