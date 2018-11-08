# frozen_string_literal: true

# :nocov:
# rubocop:disable Rails/Exit
# rubocop:disable Rails/Output
module Helpers
  # Check that there are the amount of required arguments and they are not blank.
  def self.check_arguments!(args, required, optional = 0)
    if args.count != required && args.count != required + optional
      puts "There are #{required} required arguments"
      exit(-1)
    end

    args.each do |k, v|
      if v.empty?
        puts "You have to provide a value for `#{k}'"
        exit(-1)
      end
    end
  end

  # Fetch the branch to be picked given the number parameter.
  def self.branch(number)
    m = number.match(/^(\d+)\.(\d+)./)
    "v#{m[1]}.#{m[2]}"
  end

  # Check the format as a release number.
  def self.check_release_number(number)
    return if number.match?(/^(\d)+\.(\d)+\.(\d)+$/)

    puts "Version number should follow the format X.Y.Z"
    exit(-2)
  end

  def self.in?(value, opts)
    opts.include?(value.downcase)
  end

  # Returns true if the given string value has a value representing a "yes" from
  # a y/n option.
  def self.yes?(value)
    ::Helpers.in?(value, %w[y yes])
  end

  # Returns true if the given string value has a value representing a "no" from
  # a y/n option.
  def self.no?(value)
    ::Helpers.in?(value, %w[n no])
  end

  # Returns true if the given string value has a truthy value.
  def self.truthy?(value)
    ::Helpers.in?(value, %w[t true])
  end

  # Prints a message until a proper y/n has been given. It returns true if the
  # answer was positive, false otherwise.
  def self.are_you_sure?(msg)
    answer = ""
    until ::Helpers.yes(answer) || ::Helpers.no?(answer)
      print msg
      answer = $stdin.gets.strip
    end

    ::Helpers.yes?(answer)
  end
end
# rubocop:enable Rails/Exit
# rubocop:enable Rails/Output

# :nocov:
