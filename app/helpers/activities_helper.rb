# frozen_string_literal: true

# Common methods for activities used in other helpers.
module ActivitiesHelper
  # Returns a string containing the username of the owner of the activity.
  def activity_owner(activity)
    activity_user(activity, :owner, :owner_name, "Someone")
  end

  # Returns activity action based on activity owner
  def activity_action(owner, action)
    if owner == "portus"
      "#{action} (sync)"
    else
      action
    end
  end

  # Returns a string containing the username of the recipient of the activity.
  def activity_user_recipient(activity, param)
    activity_user(activity, :recipient, param, "a user")
  end

  # Returns a string containing the name of the team of the activity. If the
  # `nested` parameter is provided, then it's supposed that the trackable has a
  # nested `team` method that has to be called to obtain the name.
  def activity_team(activity, nested = nil)
    if activity.parameters[:team]
      activity.parameters[:team]
    elsif nested
      activity.trackable.team.name
    else
      activity.trackable.name
    end
  end

  protected

  # Returns a string that represents the user of the given activity. The `method`
  # parameter is used as the preferrable source of truth (e.g. `:owner` means to
  # execute `activity.owner`). If this source is not available (e.g. the given
  # resource has been removed), then the given `param` parameter is called
  # (e.g. activity.parameters[:owner_name] if param was set to
  # `:owner_name`). If that doesn't work either, then the given `empty_user`
  # parameter is returned as-is.
  def activity_user(activity, method, param, empty_user)
    return activity.send(method).display_username if activity.send(method)

    activity.parameters[param].presence || empty_user
  end
end
