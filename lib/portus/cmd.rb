# frozen_string_literal: true

# :nocov:

require "pty"

module ::Portus
  class Cmd
    # Spawn a new command and return its exit status. It will print to stdout on
    # real time.
    def self.spawn(cmd)
      success = true

      ::PTY.spawn(cmd) do |stdout, _, pid|
        # rubocop:disable Lint/HandleExceptions
        # rubocop:disable Rails/Output
        begin
          stdout.each { |line| print line }
        rescue Errno::EIO
          # End of output
        end
        # rubocop:enable Lint/HandleExceptions
        # rubocop:enable Rails/Output

        Process.wait(pid)
        success = $CHILD_STATUS.exitstatus.zero?
      end
      success
    end
  end
end
