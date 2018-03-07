# frozen_string_literal: true

# This runner waits until a registry event related to the given tag (first
# argument) is marked as done by the background process. This runner will
# timeout if it takes just too long. Last but not least, you can pass a final
# argument with the string "pickfirst", which will tell this runner to simply
# pick the first registry event.

require "json"

TAG = ARGV.first.dup

# Returns true
def pick_first?
  ARGV.last == "pickfirst"
end

# Returns the first registry event that matches the required tag, or nil if none
# could be found.
def first_matching_tag
  r = Registry.get
  return unless r

  RegistryEvent.all.find_each do |event|
    data = JSON.parse(event.data)
    _, _, tag_name = r.get_namespace_from_event(data)
    return event.dup if tag_name == TAG
  end

  nil
end

# Returns true if the event we were interested in has been processed.
def done?
  re = pick_first? ? RegistryEvent.first : first_matching_tag
  return false unless re

  re.status.to_i == RegistryEvent.statuses[:done].to_i
end

SLEEP_TIME = 5.seconds
TIMEOUT    = 1.minute

current = 0
while current < TIMEOUT
  exit 0 if done?
  sleep SLEEP_TIME
  current += SLEEP_TIME
end

exit 1
