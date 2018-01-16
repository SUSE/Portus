# frozen_string_literal: true

# Version module
# Makes the app version available to the application itself
# Needs the git executable for all git operations
module Version
  # Returns true if the version can be extracted by using git, false
  # otherwise.
  def self.git?
    # Check that the ".git" directory at least exists.
    return false unless File.exist?(Rails.root.join(".git"))

    # Check whether we have git in our system.
    paths = ENV["PATH"].split(":")
    paths.each { |p| return true if File.executable?(File.join(p, "git")) }
    false
  end

  COMMIT = Version.git? ? `git log --pretty=format:'%h' -n 1 2>/dev/null`.chomp : nil
  TAG    = Version.git? ? `git tag --points-at $(git rev-parse HEAD) 2>/dev/null`.chomp : nil
  BRANCH = (`git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3 2>/dev/null`.chomp if Version.git?)

  # Read the version from the file.
  def self.from_file
    Version.read_from_root("VERSION")
  end

  # Read the commit from a hidden file stored by the RPM.
  def self.from_hidden
    Version.read_from_root(".gitcommit")
  end

  # Reads the given file and returns its contents of possible, otherwise it
  # returns nil
  def self.read_from_root(filename)
    file = Rails.root.join(filename)
    File.read(file).chomp if File.exist?(file)
  end

  # Version.value returns the app version
  # Priority: git tag > git branch/commit > VERSION/.gitcommit file
  def self.value
    if TAG.present?
      TAG.to_s
    elsif COMMIT.present?
      if BRANCH.present?
        "#{BRANCH}@#{COMMIT}"
      else
        "#{Version.from_file}@#{COMMIT}"
      end
    else
      commit = Version.from_hidden
      file   = Version.from_file
      commit.present? ? "#{file}@#{commit}" : file
    end
  end
end
