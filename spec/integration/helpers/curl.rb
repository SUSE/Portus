# frozen_string_literal: true

require "net/http"
require "uri"

hostname = ENV["PORTUS_MACHINE_FQDN_VALUE"]
endpoint = ARGV.first

uri = URI.parse("http://#{hostname}:3000#{endpoint}")
response = Net::HTTP.get_response(uri)

puts response.body
exit response.code == 200 ? 0 : 1
