# frozen_string_literal: true

require_relative "waiter"

# This runner waits until the LDAP background task has performed a check.
class LDAPCheckWaiter < ::Integration::Helpers::Waiter
  def initialize(sleep_time, timeout, resource)
    super(sleep_time, timeout)

    @resource = resource
  end

  # Returns true when the background job has already marked all rows from the
  # given resource as checked.
  def done?
    const = @resource.capitalize.constantize

    if @resource == "user"
      const.not_portus.where(ldap_group_checked: const.ldap_statuses[:unchecked]).none?
    else
      const.where(ldap_group_checked: const.ldap_statuses[:unchecked]).none?
    end
  end
end

waiter = LDAPCheckWaiter.new(5.seconds, 5.minutes, ARGV.first)
status = waiter.run!
exit status
