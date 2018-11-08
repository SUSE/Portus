# frozen_string_literal: true

# Re-opening from the `public_activity` gem due to a regression when upgrading
# to Rails 5.x. See: https://github.com/chaps-io/public_activity/issues/321.
module ::PublicActivity
  class Activity
    serialize :parameters, Hash
  end
end
