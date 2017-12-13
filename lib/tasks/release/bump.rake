# frozen_string_literal: true

require_relative "../helpers"

# Returns the number and the branch from the CLI arguments.
def get_branch_from_args(args)
  if args.to_hash.empty?
    puts "Usage: rake release:push[X.Y.Z]"
    exit(-1)
  end

  number = args[:number]
  ::Helpers.check_release_number(number)
  number =~ /^(\d+)\.(\d+)./
  ::Helpers.branch(number)

  [number, branch]
end

# Checkout the given branch and exit if that was not possible.
def git_checkout(branch)
  return if system("git checkout #{branch}")

  puts "There was an error checking out #{branch}. Make sure it does exists"
  exit(-3)
end

namespace :release do
  task :bump, [:number] => :environment do |_, args|
    number, branch = get_branch_from_args(args)
    git_checkout(branch)

    FileUtils.copy("CHANGELOG.md", ".CHANGELOG.md.release.rake")
    system("$EDITOR CHANGELOG.md")
    changed = FileUtils.identical?("CHANGELOG.md", ".CHANGELOG.md.release.rake")
    FileUtils.rm(".CHANGELOG.md.release.rake")

    unless changed
      msg = "CHANGELOG.md unchanged. Are you sure you want to continue? (yes/no) "
      exit(-4) unless ::Helpers.are_you_sure?(msg)
    end

    open("VERSION", "w") { |f| f.write(number) }

    puts "Update VERSION with #{number}"
    system("git add VERSION CHANGELOG.md")
    system("git commit -m \"Bump version #{number}\"")
    system("git tag #{number} -s")
    system("git push --tags origin HEAD")
  end
end
