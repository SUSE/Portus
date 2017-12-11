# frozen_string_literal: true

namespace :portus do
  desc "Get general info about the running instance"
  task info: :environment do
    # We cannot pass it with the dependency-syntax because we need to pass it an
    # argument.
    Rake::Task["cconfig:info"].reenable
    Rake::Task["cconfig:info"].invoke("portus")

    puts "\nPortus version: #{Version.value}"
  end
end
