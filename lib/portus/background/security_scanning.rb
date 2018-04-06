# frozen_string_literal: true

require "portus/security"

module Portus
  module Background
    # SecurityScanning represents a task for checking vulnerabilities of tags that
    # have not been scanned yet.
    class SecurityScanning
      # Returns how many seconds has to pass between each loop for this
      # background service.
      def sleep_value
        10
      end

      def work?
        ::Portus::Security.enabled? && Tag.exists?(scanned: Tag.statuses[:scan_none])
      end

      def enabled?
        ::Portus::Security.enabled?
      end

      def disable?
        false
      end

      # execute! updates the vulnerabilities of all tags which have not been
      # scanned yet. Note that this is done digest-wise, so tags which have
      # already been scanned might be updated as a side-effect of a tag with the
      # same digest that had not been scanned until then.
      def execute!
        digests = []

        Tag.where(scanned: Tag.statuses[:scan_none]).find_each do |tag|
          # This may happen when pushing multiple images with the same digest at
          # once, while a previous one has already been scanned on a previous
          # iteration.
          next if tag.digest.present? && digests.include?(tag.digest)

          # Mark as work in progress. This is important in case there is a push in
          # progress.
          tag.update_vulnerabilities(scanned: Tag.statuses[:scan_working])

          # Fetch vulnerabilities. If there was an error and nil was returned,
          # simply skip this iteration.
          sec = ::Portus::Security.new(tag.repository.full_name, tag.name)
          vulns = sec.vulnerabilities
          next unless vulns

          # And now update the tag with the vulnerabilities.
          dig = update_tag(tag, vulns)
          digests << dig if dig
        end

        check_failed!
      end

      def to_s
        "Security scanning"
      end

      protected

      # update_tag will mark the scanning as done for the given tag and assign
      # to it the given vulnerabilities. This action will also affect tags with
      # the same digest. This is done in a transaction, while taking into
      # consideration possible changes on the given tag that may have happened
      # meanwhile.
      #
      # It returns the affected digest.
      def update_tag(tag, vulns)
        digest = nil

        ActiveRecord::Base.transaction do
          # If the tag no longer exists, then we need to raise a Rollback
          # exception to leave early and cleanly from the transaction.
          begin
            tag = tag.reload
          rescue ActiveRecord::RecordNotFound
            raise ActiveRecord::Rollback
          end

          if tag&.scanned != Tag.statuses[:scan_none]
            tag.update_vulnerabilities(vulnerabilities: vulns, scanned: Tag.statuses[:scan_done])
            digest = tag.digest
          end
        end

        digest
      end

      # If not all tags where marked as done, then we have a problem (either
      # Clair was temporarily unavailable, or we are hitting a bug). In that
      # case, log the issue and mark the affected tags as not-scanned, so they
      # can be picked up in following iterations.
      def check_failed!
        tags = Tag.where.not(scanned: Tag.statuses[:scan_done])
        return if tags.empty?

        Rails.logger.warn "Some tags were not marked as done. This may happen" \
                          " either because the security scanner had a temporary problem, or" \
                          " because there is a bug. They will be picked up in the next iteration."
        tags.update_all(scanned: Tag.statuses[:scan_none])
      end
    end
  end
end
