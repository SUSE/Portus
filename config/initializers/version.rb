# Version module
# Makes the app version available to the application itself
# Needs the git executable for all git operations
module Version
  # Returns true if git is in the system, false otherwise.
  def self.git?
    paths = ENV["PATH"].split(":")
    paths.each { |p| return true if File.executable?(File.join(p, "git")) }
    false
  end

  BRANCH = Version.git? ? `git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3  2>/dev/null`.chomp : nil
  COMMIT = Version.git? ? `git log --pretty=format:'%h' -n 1 2>/dev/null`.chomp : nil
  TAG    = Version.git? ? `git tag --points-at $(git rev-parse HEAD) 2>/dev/null`.chomp : nil

  # Version.value returns the app version
  # Priority: git tag > git branch/commit > VERSION file
  def self.value
    if TAG.present?
      "#{TAG}"
    elsif COMMIT.present?
      if BRANCH.present?
        "#{BRANCH}@#{COMMIT}"
      else
        "#{COMMIT}"
      end
    else
      version = Rails.root.join("VERSION")
      File.read(version).chomp if File.exists?(version)
    end
  end
end
