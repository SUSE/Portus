# frozen_string_literal: true

require "portus/security"

if ARGV.size != 2
  puts "Usage: rails runner bin/security.rb <image> <tag>"
  exit 1
end

image, tag = ARGV
sec = ::Portus::Security.new(image, tag)
vulns = sec.vulnerabilities

vulns.each do |name, result|
  hsh = {}

  n = name.to_s.capitalize
  print "#{n}\n" + ("=" * n.size) + "\n"

  if result.nil?
    print "\nWork in progress...\n"
    next
  end

  result.each do |v|
    hsh[v["Severity"]] = 0 unless hsh.include?(v["Severity"])
    hsh[v["Severity"]] += 1

    puts "#{v["Name"]}: #{v["Severity"]}"
    puts ""
    puts v["Link"].to_s
    puts "---------------"
  end

  print "\nFound #{result.size} vulnerabilities:\n\n"
  hsh.each { |k, v| puts "#{k}: #{v}" }
  puts ""
end
