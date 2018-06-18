# frozen_string_literal: true

require "net/ldap"
require_relative "shared"

clean_db!
create_registry!
User.create!(
  username: "pfabra",
  password: "giecftw1918",
  email:    "pfabra@iec.cat",
  bot:      true
)

##
# Set parameters and initialize LDAP object.

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

ldap = Net::LDAP.new(params)

##
# Add a test user.

ldap.add(
  dn:         "uid=jverdaguer,dc=example,dc=org",
  attributes: {
    cn:           "Jacint Verdaguer",
    givenName:    "Jacint",
    sn:           "Verdaguer",
    displayName:  "Jacint Verdaguer",
    objectclass:  %w[top inetorgperson],
    userPassword: Net::LDAP::Password.generate(:md5, "folgueroles"),
    mail:         "jverdaguer@renaixenca.cat"
  }
)

puts "#{ldap.get_operation_result.message} (code #{ldap.get_operation_result.code})."
puts "Parameters used: #{params}" if ldap.get_operation_result.code != 0
