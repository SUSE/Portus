require "portus/security"

if ARGV.size != 2
  puts "Usage: rails runner bin/security.rb <image> <tag>"
  exit 1
end

image, tag = ARGV
sec = ::Portus::Security.new(image, tag)
vulns = sec.vulnerabilities

hsh = { "High" => 0, "Normal" => 0, "Low" => 0 }

puts ""
vulns.each do |v|
  hsh[v["Severity"]] = 0 unless hsh.include?(v["Severity"])
  hsh[v["Severity"]] += 1

  puts "#{v["Name"]}: #{v["Severity"]}"
  puts ""
  puts v["Link"].to_s
  puts "---------------"
end

print "\nFound #{vulns.size} vulnerabilities:\n\n"
hsh.each { |k, v| puts "#{k}: #{v}" }
