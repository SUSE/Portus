# frozen_string_literal: true

require_relative "../helpers"

namespace :release do
  desc "Prepare new release"
  task :prepare, [:number] => :environment do |_, args|
    if args.to_hash.empty?
      puts "Usage: rake release:prepare[X.Y.Z]"
      exit(-1)
    end

    number = args[:number]
    ::Helpers.check_release_number(number)
    branch = ::Helpers.branch(number)

    puts "Things you have to do to prepare the release for #{number}"
    puts "1- Create new branch #{branch} if it does not exist"
    puts "2- Checkout #{branch}" # TODO, what happens if it already exists?
    puts "3- Review Gemfile.lock. Review the gem versions."
    puts "4- Test and small fixes"
  end
end
