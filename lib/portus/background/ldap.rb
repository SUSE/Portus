# frozen_string_literal: true

require "portus/errors"

module Portus
  module Background
    # LDAP keeps track of some tasks to be done on the background for LDAP
    # maintenance.
    class LDAP
      # The number of days in which we should force a recheck.
      FORCE_CHECK_IN_DAYS = 7

      def sleep_value
        10
      end

      # Returns true if there's work to be done.
      def work?
        return false unless enabled?

        # Are there teams or users to be checked?
        Team.where(ldap_group_checked: Team.ldap_statuses[:unchecked]).any? ||
          User.not_portus.where(ldap_group_checked: User.ldap_statuses[:unchecked]).any?
      end

      # Returns true only if LDAP is enabled.
      def enabled?
        APP_CONFIG.enabled?("ldap") && APP_CONFIG.enabled?("ldap.group_sync")
      end

      def execute!
        Rails.logger.tagged(:ldap) { Rails.logger.info "Starting check..." }

        force_check!
        team_count = execute_team!
        execute_user!(team_count)
      end

      # Once enabled, it cannot be disabled.
      def disable?
        false
      end

      def to_s
        "LDAP synchronization"
      end

      protected

      # Updates the rows which should be checked even if they were already
      # checked in the past.
      def force_check!
        # Disable all hidden teams that weren't disabled yet.
        Team.where(hidden: true).where.not(ldap_group_checked: Team.ldap_statuses[:disabled])
            .update_all(ldap_group_checked: Team.ldap_statuses[:disabled])

        # Force the check for teams that have never been checked (checked_at is
        # nil and they have not been disabled), or that they have been checked a
        # long time ago.
        Team
          .where(checked_at: nil)
          .where.not(ldap_group_checked: Team.ldap_statuses[:disabled])
          .or(
            Team.where(ldap_group_checked: Team.ldap_statuses[:checked])
                .where("checked_at < ?", FORCE_CHECK_IN_DAYS.days.ago)
          ).update_all(ldap_group_checked: Team.ldap_statuses[:unchecked])
      end

      # Processes the LDAP check for teams and returns the teams that have been
      # updated.
      def execute_team!
        # For each team to be checked, let's check LDAP groups. Notice that they
        # both have a query which is nearly identical. This is because we need
        # #find_each for batch processing, but this method doesn't return the
        # rows that have been affected. So, instead, we first get the count
        # (which should be pretty cheap), and then we do the actual batch
        # processing.
        count = Team.where(ldap_group_checked: Team.ldap_statuses[:unchecked]).count
        Team.where(ldap_group_checked: Team.ldap_statuses[:unchecked])
            .find_each(&:ldap_add_members!)
        count
      end

      # Processes the LDAP group membership check for users. This seems
      # redundant at first, but this serves for cases such as:
      #   1. Teams are checked.
      #   2. A couple of hours later, a user logs in for the first time and
      #      gets created.
      #   3. Instead of waiting `FORCE_CHECK_IN_DAYS` days, let's insert them
      #      now.
      def execute_user!(team_count)
        # If we just updated all the available teams, then we don't have to
        # re-check again, because all the possibilities have already been
        # crossed.
        if team_count == Team.all_non_special.size
          User.not_portus.update_all(ldap_group_checked: User.ldap_statuses[:checked])
        else
          User.not_portus.where(ldap_group_checked: User.ldap_statuses[:unchecked])
              .find_each(&:ldap_add_as_member!)
        end
      end
    end
  end
end
