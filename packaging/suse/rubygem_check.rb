# frozen_string_literal: true

##
# Get build dir.

unless Dir.exist?("build")
  puts <<~HERE
    You are supposed to be running this script inside of packaging/suse and after a
    successful run of `make_spec.sh`.
  HERE
  exit 1
end

dir = ""
Dir.entries("build").each do |d|
  next if d == "." || d == ".."

  dir = "build/#{d}"
end

##
# Fetch current gems.

cmd = "bundle show | tail -n +2 | awk '{ print $2 \" \" $3 }' | tr -d '()'"
current = {}
`cd #{dir} && #{cmd}`.split("\n").each do |row|
  name, version = row.split(" ")
  current[name.strip] = version.strip
end

##
# Fetch the ones on OBS.

list = `osc ls Virtualization:containers:Portus | grep rubygem`.split("\n")
found = {}
removed = {}

list.each do |rg|
  pkg = rg.gsub("rubygem-", "")
  idx = pkg.index(/\-\d/)
  name = idx ? pkg.slice(0..idx - 1) : pkg

  if current[name]
    found[rg] = name
  elsif name != "gem2rpm"
    removed[rg] = name
  end
end

keys = current.keys - found.values
unless keys.empty?
  print "The following gems are missing from OBS:\n\n"
  keys.each { |pkg| puts "  * #{pkg}" }
  puts
end

unless removed.empty?
  print "The following packages are not used by Portus:\n\n"
  removed.each { |pkg| puts "  * #{pkg.first}" }
end
