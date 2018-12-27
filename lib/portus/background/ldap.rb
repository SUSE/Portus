# frozen_string_literal: true

require "portus/errors"

module Portus
  module Background
    # LDAP keeps track of some tasks to be done on the background for LDAP
    # maintenance.
    class LDAP
      def sleep_value
        10
      end

      # Returns true if there's work to be done.
      def work?
        return false unless enabled?

        # Are there teams to be checked?
        Team.where(ldap_group_checked: Team.ldap_statuses[:unchecked]).any?
      end

      # Returns true only if LDAP is enabled.
      def enabled?
        APP_CONFIG.enabled?("ldap") && APP_CONFIG.enabled?("ldap.group_sync")
      end

      def execute!
        # For each team to be checked, let's check LDAP groups.
        Team.where(ldap_group_checked: Team.ldap_statuses[:unchecked])
            .find_each(&:ldap_add_members!)
      end

      # Once enabled, it cannot be disabled.
      def disable?
        false
      end

      def to_s
        "LDAP synchronization"
      end
    end
  end
end
