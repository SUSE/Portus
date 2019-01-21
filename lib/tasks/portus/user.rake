# frozen_string_literal: true

require_relative "../helpers"

# Exits with a proper error message of there is no registry.
def check_registry!
  return if Registry.any?

  puts <<~HERE

    ERROR: There is no registry on the DB! You can either call the portus:create_registry
    task, or log in as an administrator into Portus and fill in the form that
    will be presented to you.
  HERE
  exit(-1)
end

namespace :portus do
  desc "Create a user"
  task :create_user, %i[username email password admin] => :environment do |_, args|
    # Initial checks.
    ::Helpers.check_arguments!(args, 4)
    check_registry!

    u = User.create!(
      username: args["username"],
      password: args["password"],
      email:    args["email"],
      admin:    args["admin"]
    )

    # Inform the user if the name of the namespace had to change.
    if u.username != u.namespace.name
      puts <<~HERE

        NOTE: the user you just created contained characters that are not accepted for
        naming namespaces. Because of this, you've got the following:

          * User name: '#{u.username}'
          * Personal namespace: '#{u.namespace.name}'
      HERE
    end
  end

  desc "Clear out all the passwords from users which are not bots"
  task clear_passwords: :environment do
    User.not_portus.where(bot: false).update_all(encrypted_password: "")
  end
end
