# frozen_string_literal: true

require "portus/errors"

module Portus
  module Background
    # Sync synchronizes the contents from the registry into the DB.
    class Sync
      # Returns how many seconds has to pass between each loop for this
      # synchronization to happen.
      def sleep_value
        20
      end

      # Returns always true because this does not depend on some configuration
      # options.
      def work?
        true
      end

      # Simply fetches the catalog from the registry and calls
      # `update_registry!`.
      def execute!
        ::Registry.find_each do |registry|
          begin
            cat = registry.client.catalog
            Rails.logger.debug "Catalog:\n #{cat}"

            # Update the registry in a transaction, since we don't want to leave
            # the DB in an unknown state because of an update failure.
            ActiveRecord::Base.transaction { update_registry!(cat) }
          rescue EOFError, *::Portus::Errors::NET,
                 ::Portus::Errors::NoBearerRealmException, ::Portus::Errors::AuthorizationError,
                 ::Portus::Errors::NotFoundError, ::Portus::Errors::CredentialsMissingError => e
            Rails.logger.warn "Exception: #{e.message}"
          end
        end
      end

      def to_s
        "Registry synchronization"
      end

      protected

      # This method updates the database of this application with the given
      # registry contents.
      def update_registry!(catalog)
        dangling_repos = Repository.all.pluck(:id)

        # In this loop we will create/update all the repos from the catalog.
        # Created/updated repos will be removed from the "repos" array.
        catalog.each do |r|
          if r["tags"].blank?
            Rails.logger.debug "skip upload not finished repo #{r["name"]}"
          else
            repository = Repository.create_or_update!(r)
            dangling_repos.delete repository.id unless repository.nil?
          end
        end

        # At this point, the remaining items in the "repos" array are repos that
        # exist in the DB but not in the catalog. Remove all of them.
        portus = User.find_by(username: "portus")
        Tag.where(repository_id: dangling_repos).find_each { |t| t.delete_and_update!(portus) }
        Repository.where(id: dangling_repos).find_each { |r| r.delete_and_update!(portus) }
      end
    end
  end
end
