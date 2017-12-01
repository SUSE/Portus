require "portus/security"

module Portus
  module Background
    # SecurityScanning represents a task for checking vulnerabilities of tags that
    # have not been scanned yet.
    class SecurityScanning
      def work?
        ::Portus::Security.enabled? && Tag.exists?(scanned: Tag.statuses[:scan_none])
      end

      def execute!
        Tag.where(scanned: Tag.statuses[:scan_none]).find_each do |tag|
          # Mark as work in progress. This is important in case there is a push in
          # progress.
          tag.update_columns(scanned: Tag.statuses[:scan_working])

          # Fetch vulnerabilities.
          sec = ::Portus::Security.new(tag.repository.full_name, tag.name)
          vulns = sec.vulnerabilities

          # Now it's time to update the columns and mark the scanning as done. That
          # being said, it may have happened that during the scanning process a push
          # or a delete action has been performed against this tag. For this reason,
          # in a transaction we will reload it and check if any of these conditions
          # changed. If not, then we will proceed with the change.
          ActiveRecord::Base.transaction do
            # If the tag no longer exists, then we need to raise a Rollback
            # exception to leave early and cleanly from the transaction.
            begin
              tag = tag.reload
            rescue ActiveRecord::RecordNotFound
              raise ActiveRecord::Rollback
            end

            if tag&.scanned != Tag.statuses[:scan_none]
              tag.update_columns(vulnerabilities: vulns, scanned: Tag.statuses[:scan_done])
            end
          end
        end
      end

      def to_s
        "Security scanning"
      end
    end
  end
end
