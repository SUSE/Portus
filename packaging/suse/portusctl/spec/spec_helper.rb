require_relative "../lib/portusctl"

require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = "packaging/suse/portusctl/spec/vcr_cassettes"
  c.hook_into :webmock
  c.ignore_localhost = true

  # So code coverage reports can be submitted to codeclimate.com
  c.ignore_hosts "codeclimate.com"

  # To debug when a VCR goes wrong.
  # c.debug_logger = $stdout
end
