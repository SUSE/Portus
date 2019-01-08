# frozen_string_literal: true

# Integration is the module that encapsulates all the utilities for integration
# tests.
module Integration
  # Helpers contains helper classes for integration tests.
  module Helpers
    # Waiter implements a simple loop with a given timeout and a sleep
    # time. This class is meant to be subclassed and the resulting class should
    # at least implement the `done?` method, which simply returns a boolean
    # telling the loop whether or not we are done waiting. If `done?` returns a
    # falsey value, then it will sleep for a given sleep time and then run
    # `done?` again. This will be done at least until the given timeout is
    # reached. If `done?` returns a truthy value before that, then it will
    # return early with a success value.
    class Waiter
      def initialize(sleep_time, timeout)
        @sleep_time = sleep_time
        @timeout    = timeout
      end

      # Returns 0 if the loop was successful, and 1 otherwise. Thus, the
      # returned value should be used as a parameter for an `exit` call. You
      # should call this method right after instantiating a Waiter object.
      def run!
        current = 0
        while current < @timeout
          return 0 if done?

          sleep @sleep_time
          current += @sleep_time
        end

        1
      end

      def done?
        true
      end
    end
  end
end
