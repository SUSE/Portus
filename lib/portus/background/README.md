## Background tasks

This is the documentation for writing and maintaining background tasks. All the
tasks defined in this directory should be picked up by the Rails runner:
`bin/background.rb`. Make sure that when you write a new background task this
has been added into the `they` array.

### Interface

The `bin/background.rb` expects the following methods to be implemented by a
task:

- `sleep_value`: simply return an integer which contains the time span in
  seconds between executions. Note that the `sleep_value` of all tasks have to
  be divisible by the one with the lowest value.
- `work?`: returns true if the task can perform an execution, otherwise it
  returns false.
- `execute!`: performs an execution. This is the bulk of the background task.
- `disable?`: returns true if the task can be entirely removed after some
  time. This might be useful for tasks which need to perform at least one
  execution and leave. If your task can be disabled in some situation, then you
  should provide `disable_message`, which returns a string.
- `to_s`: returns a string with a fancy name for your task.
