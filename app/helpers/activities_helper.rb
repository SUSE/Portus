# Common methods for activities used in other helpers.
module ActivitiesHelper
  # Returns a string containing the username of the owner of the activity.
  def activity_owner(activity)
    if activity.owner
      activity.owner.display_username
    elsif activity.parameters[:owner_name].blank?
      "Someone"
    else
      activity.parameters[:owner_name]
    end
  end
end
