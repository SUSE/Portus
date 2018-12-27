# frozen_string_literal: true

require "portus/errors"

module Portus
  module Background
    # Sync synchronizes the contents from the registry into the DB.
    class Sync
      def initialize
        @executed = false
      end

      # Returns how many seconds has to pass between each loop for this
      # synchronization to happen.
      def sleep_value
        20
      end

      def work?
        return false unless APP_CONFIG.enabled?("background.sync")

        val = APP_CONFIG["background"]["sync"]["strategy"]
        case val
        when "update-delete", "update"
          true
        when "on-start"
          !@executed
        when "initial"
          !@executed && Repository.none?
        else
          Rails.logger.error "Unrecognized value '#{val}' for strategy"
          false
        end
      end

      def enabled?
        if APP_CONFIG.enabled?("background.sync")
          strategy = APP_CONFIG["background"]["sync"]["strategy"]
          if strategy == "initial" && Repository.any?
            Rails.logger.info "`#{self}` was disabled because strategy is set to " \
                              "'initial' and the database is not empty"
            false
          else
            true
          end
        else
          false
        end
      end

      # Simply fetches the catalog from the registry and calls
      # `update_registry!`.
      #
      # If an exception was raised when fetching the catalog (e.g. timeout),
      # then it will handle it by logging such exception. Moreover, sometimes
      # the given catalog object contains nil values for the `tags` field. This
      # happens when there were exceptions being raised when fetching the list
      # of tags for that particular repository. In these cases the
      # `update_registry!` method will never remove them to avoid false
      # positives.
      def execute!
        ::Registry.find_each do |registry|
          cat = registry.client.catalog
          Rails.logger.debug "Catalog:\n #{cat}"

          # Update the registry in a transaction, since we don't want to leave
          # the DB in an unknown state because of an update failure.
          ActiveRecord::Base.transaction { update_registry!(cat) }
          @executed = true
        rescue ::Portus::RequestError, ::Portus::Errors::NotFoundError,
               ::Portus::RegistryClient::ManifestError,
               ::Portus::Errors::NoBearerRealmException, ::Portus::Errors::AuthorizationError,
               ::Portus::Errors::CredentialsMissingError => e
          Rails.logger.warn "Exception: #{e.message}"
        end
      end

      # This task will be asked to be disable if the strategy was set to
      # "on-start" or "initial", and the first execution has already been done.
      def disable?
        strategy = APP_CONFIG["background"]["sync"]["strategy"]
        if strategy == "initial" || strategy == "on-start"
          @executed
        else
          false
        end
      end

      def disable_message
        "task was ordered to execute once, and this has already been performed"
      end

      def to_s
        "Registry synchronization"
      end

      protected

      # This method updates the database of this application with the given
      # registry contents. If a repository had a blank `tags` field, then this
      # method will not removed (because maybe the image is still uploading, or
      # there was a temporary error when fetching the tags).
      def update_registry!(catalog)
        dangling_repos = Repository.all.pluck(:id)

        # In this loop we will create/update all the repos from the catalog.
        # Created/updated repos will be removed from the "repos" array.
        catalog.each do |r|
          repository = if r["tags"].blank?
                         Rails.logger.debug "skipping repo with no tags: #{r["name"]}"
                         Repository.from_catalog(r["name"])
                       else
                         Repository.create_or_update!(r)
                       end

          dangling_repos.delete repository.id unless repository.nil?
        end

        # At this point, the remaining items in the "repos" array are repos that
        # exist in the DB but not in the catalog. Remove all of them.
        delete_maybe!(dangling_repos)

        # Check that no events have happened while doing all this.
        check_events!
      end

      # Delete the given repositories unless the configuration does not allow it.
      def delete_maybe!(repositories)
        return if APP_CONFIG["background"]["sync"]["strategy"] == "update"

        portus = User.portus
        Tag.where(repository_id: repositories).find_each { |t| t.delete_by!(portus) }
        Repository.where(id: repositories).find_each { |r| r.delete_by!(portus) }
      end

      # Raises an ActiveRecord::Rollback exception if there are registry events
      # ready to be fetched.
      def check_events!
        return unless RegistryEvent.exists?(status: RegistryEvent.statuses[:fresh])

        raise ActiveRecord::Rollback
      end
    end
  end
end
