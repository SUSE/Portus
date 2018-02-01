# frozen_string_literal: true

abort("Please run this using `bundle exec rake`") unless ENV["BUNDLE_BIN_PATH"]
require "html-proofer"

desc "Test the website"
task :test do
  options = {
    check_sri:       true,
    check_html:      true,
    check_img_http:  true,
    check_opengraph: true,
    typhoeus:        {
      timeout: 120
    },
    cache:           {
      timeframe: "6w"
    }
  }
  HTMLProofer.check_directory("./_site", options).run
end

task default: [:test]
