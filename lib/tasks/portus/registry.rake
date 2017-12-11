# frozen_string_literal: true

require_relative "../helpers"

namespace :portus do
  desc "Create a registry"
  task :create_registry, %i[name hostname use_ssl external] => :environment do |_, args|
    ::Helpers.check_arguments!(args, 3, 1)

    if Registry.any?
      puts "There is already a registry configured!"
      exit(-1)
    end

    registry = Registry.new(
      name:              args[:name],
      hostname:          args[:hostname],
      use_ssl:           args[:use_ssl],
      external_hostname: args[:external]
    )
    msg = registry.reachable?
    unless msg.empty?
      puts "\nRegistry not reachable:\n#{registry.inspect}\n#{msg}\n"
      exit(-1)
    end
    registry.save
  end
end
