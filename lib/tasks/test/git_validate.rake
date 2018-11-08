# frozen_string_literal: true

require "English"

# We will start reviewing commit from this one.
FROM_SHA = "bef0fe19d3a5d1e215a4fbadd496ad61699e63f9"

# Performs the given command, and optionally spits the output as it comes.
def spawn_cmd(cmd:, output: true)
  status = 0

  PTY.spawn(cmd) do |stdout, _, pid|
    if output
      # rubocop:disable Lint/HandleExceptions
      begin
        stdout.each { |line| print line }
      rescue Errno::EIO
        # End of output
      end
      # rubocop:enable Lint/HandleExceptions
    end

    Process.wait(pid)
    status = $CHILD_STATUS.exitstatus
  end
  status
end

# Returns true if the `git-validation` command is available.
def git_validation?
  spawn_cmd(cmd: "which git-validation", output: false).zero?
end

# Returns the range of commits to be considered by git-validation.
def range
  return ENV["TRAVIS_COMMIT_RANGE"] if ENV["TRAVIS_COMMIT_RANGE"].present?

  "#{FROM_SHA}..HEAD"
end

namespace :test do
  desc "Run git-validate on the source code"
  task git: :environment do
    unless git_validation?
      puts "[TEST] The git-validation command could not be found"
      exit 1
    end

    path = Rails.root
    puts "cd #{path} && git-validation -range #{range}"
    status = spawn_cmd(cmd: "cd #{path} && git-validation -range #{range}")
    exit status
  end
end
