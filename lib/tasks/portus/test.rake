# frozen_string_literal: true

require "pty"

# Spawn a new command and return its exit status. It will print to stdout on
# real time.
def spawn_cmd(cmd)
  status = 0

  PTY.spawn(cmd) do |stdout, _, pid|
    begin
      stdout.each { |line| print line }
    rescue Errno::EIO
      puts "EOI"
    end

    Process.wait(pid)
    status = $CHILD_STATUS.exitstatus
  end
  status
end

namespace :portus do
  desc "Properly test Portus"
  task :test do |_, args|
    tags = args.extras.map { |a| "--tag #{a}" }
    tags << "--tag ~integration" if ENV["TRAVIS"] == "true"

    # Run normal tests + integration.
    ENV["INTEGRATION_LDAP"] = nil
    status = spawn_cmd("rspec spec #{tags.join(" ")}")
    exit(status) if status != 0
    exit(0) if ENV["TRAVIS"] == "true"

    # Run LDAP integration tests.
    ENV["INTEGRATION_LDAP"] = "t"
    tags << "--tag integration" unless args.extras.include?("integration")
    status = spawn_cmd("rspec spec #{tags.join(" ")}")
    exit(status)
  end
end
