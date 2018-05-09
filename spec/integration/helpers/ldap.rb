# frozen_string_literal: true

require "portus/ldap"

##
# Define a class that mocks stuff like `params` and exit methods.

class IntegrationLDAP < Portus::LDAP
  attr_reader :params
  attr_accessor :session

  def initialize(params)
    @params  = params
    @session = {}
  end

  def fail(_obj)
    exit 1
  end

  alias fail! fail

  def success!(user)
    puts "name: #{user.username}, email: #{user.email}, " \
         "admin: #{user.admin}, display_name: #{user.display_name}"
    exit 0
  end
end

##
# Setup APP_CONFIG according to some possible modifications.

originals = {}

ARGV[2].to_s.split(",").each do |env|
  k, val = env.split("=")

  *key, last = k.split(":")
  hsh = APP_CONFIG["ldap"]
  key.each { |ke| hsh = hsh[ke] }

  originals[k] = hsh[last].dup
  hsh[last] = val
end

# Regardless of what happens in the end, set the APP_CONFIG to the original
# values.
at_exit do
  originals.each do |k, v|
    *key, last = k.split(":")
    hsh = APP_CONFIG["ldap"]
    key.each { |ke| hsh = hsh[ke] }
    hsh[last] = v
  end
end

##
# Try to authenticate!

ldap = IntegrationLDAP.new(user: { username: ARGV.first.dup, password: ARGV[1].dup })
ldap.authenticate!
