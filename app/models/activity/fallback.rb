# frozen_string_literal: true

# Activity holds utility methods to update activity records depending on the
# model including this module.
module Activity
  # Fallback has a set of methods that manage trackable types for existing
  # activities.
  module Fallback
    # fallback_activity updates the model including this method by setting a new
    # type an id for all the rows.
    def fallback_activity(type, id)
      PublicActivity::Activity.where(trackable: self).update_all(
        trackable_type: type,
        trackable_id:   id,
        recipient_type: nil
      )
    end
  end
end
