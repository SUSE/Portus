# frozen_string_literal: true

require "optparse"
require "ostruct"
require "json"

require "portus/health"

# Returns true if the given string value contains a truthy value.
def truthy?(val)
  v = val&.downcase
  v == "t" || v == "y" || v == "1"
end

##
# Parse options.

options = OpenStruct.new(quiet: false, components: [])

# It can come as flags.
OptionParser.new do |opt|
  opt.on("-q", "--quiet")                         { options.quiet = true }
  opt.on("-c COMPONENT", "--component COMPONENT") { |o| options.components << o }
end.parse!

# It can also come as environment variables.
options.quiet = true if truthy?(ENV["PORTUS_HEALTH_QUIET"])
(1..5).each do |n|
  v = ENV["PORTUS_HEALTH_COMPONENT_#{n}"]
  break if v.nil?

  options.components << v
end

##
# Actual call.

response, _success = ::Portus::Health.check
hsh = if options.components.any?
        response.select { |k, _v| options.components.include?(k) }
      else
        response
      end

puts JSON.pretty_generate(hsh) unless options.quiet

success = hsh.all? { |_, v| v[:success] }
exit success ? 0 : 1
