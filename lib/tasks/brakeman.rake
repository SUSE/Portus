# frozen_string_literal: true

if Rails.env.development?
  desc "Run Brakeman security checks"
  task :brakeman do
    require "brakeman"

    Brakeman.run(
      app_path:     File.expand_path("../..", __dir__),
      print_report: true,
      exit_on_warn: true
    )
  end
end
