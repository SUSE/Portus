require "pty"

# Spawn a new command and return its exit status. It will print to stdout on
# real time.
def spawn_cmd(cmd)
  status = 0

  PTY.spawn(cmd) do |stdout, _, pid|
    # rubocop:disable Lint/HandleExceptions
    begin
      stdout.each { |line| print line }
    rescue Errno::EIO
      # End of output
    end
    # rubocop:enable Lint/HandleExceptions

    Process.wait(pid)
    status = $CHILD_STATUS.exitstatus
  end
  status
end

namespace :portus do
  desc "Create the account used by Portus to talk with Registry's API"
  task create_api_account: :environment do
    User.create!(
      username: "portus",
      password: Rails.application.secrets.portus_password,
      email:    "portus@portus.com",
      admin:    true
    )
  end

  desc "Create a user"
  task :create_user, [:username, :email, :password, :admin] => :environment do |_, args|
    args.each do |k, v|
      if v.empty?
        puts "You have to provide a value for `#{k}'"
        exit(-1)
      end
    end

    u = User.create!(
      username: args["username"],
      password: args["password"],
      email:    args["email"],
      admin:    args["admin"]
    )

    if u.username != u.namespace.name
      puts <<HERE

NOTE: the user you just created contained characters that are not accepted for
naming namespaces. Because of this, you've got the following:

  * User name: '#{u.username}'
  * Personal namespace: '#{u.namespace.name}'
HERE
    end
  end

  desc "Give 'admin' role to a user"
  task :make_admin, [:username] => [:environment] do |_, args|
    unless args[:username]
      puts "Specify a username, as in"
      puts " rake portus:make_admin[username]"
      puts "valid usernames are"
      puts "#{User.pluck(:username)}"
      exit(-1)
    end
    u = User.find_by_username(args[:username])
    if u.nil?
      puts "#{args[:username]} not found in database"
      puts "valid usernames are"
      puts "#{User.pluck(:username)}"
      exit(-2)
    end
    u.admin = true
    u.save
    if u.nil?
      puts "Sorry something went wrong and I couldn't set this user as admin."
      exit(-3)
    end
  end

  desc "Update the manifest digest of tags"
  task :update_tags, [:update] => [:environment] do |_, args|
    # Warning
    puts <<HERE
This rake task may take a while depending on how many images have been stored
in your private registry. If you are running this in production it's
recommended that the registry is running in "readonly" mode, so there are no
race conditions with concurrent accesses.

HERE

    unless ENV["PORTUS_FORCE_DIGEST_UPDATE"]
      print "Are you sure that you want to proceed with this ? (y/N) "
      opt = $stdin.gets.strip
      exit 0 if opt != "y" && opt != "Y" && opt != "yes"
    end

    # Fetch the tags to be updated.
    update = args[:update] == "true" || args[:update] == "t"
    if update
      tags = Tag.all
    else
      tags = Tag.where("tags.digest='' OR tags.image_id=''")
    end

    # Some information on the amount of tags to be updated.
    if tags.empty?
      puts "There are no tags to be updated."
      exit 0
    else
      puts "Updating a total of #{tags.size} tags..."
    end

    # And for each tag fetch its digest and update the DB.
    client = Registry.get.client
    tags.each_with_index do |t, index|
      repo_name = t.repository.name
      puts "[#{index + 1}/#{tags.size}] Updating #{repo_name}/#{t.name}"

      begin
        id, digest, = client.manifest(t.repository.name, t.name)
        t.update_attributes(digest: digest, image_id: id)
      rescue StandardError => e
        puts "Could not get the manifest for #{repo_name}: #{e.message}"
      end
    end
    puts
  end

  # NOTE: this is only available from 2.0.x -> 2.1.x.
  # TODO: (mssola) prevent in the future to execute this if the version of
  # Portus is higher than 2.1.x. (should be deprecated in 2.2, and removed later
  # on).
  desc "Update personal namespaces"
  task update_personal_namespaces: :environment do
    ActiveRecord::Base.transaction do
      User.all.find_each do |u|
        namespace = Namespace.find_by(name: u.username)
        raise "There is no valid personal namespace for #{u.username}!" if namespace.nil?
        u.update_attributes(namespace: namespace)
      end
    end
  end

  # NOTE: this is only available from 2.0.x -> 2.1.x.
  # TODO: (mssola) prevent in the future to execute this if the version of
  # Portus is higher than 2.1.x. (should be deprecated in 2.2, and removed later
  # on).
  desc "Update LDAP user names"
  task update_ldap_names: :environment do
    unless APP_CONFIG.enabled?("ldap")
      puts "This only applies to LDAP setups..."
      exit 0
    end

    unless ActiveRecord::Base.connection.column_exists?(:users, :ldap_name)
      puts "The User model does not have :ldap_name. Probably an old version..."
      exit 0
    end

    puts "Users to be updated:"
    count = 0
    User.all.find_each do |u|
      if !u.ldap_name.blank? && u.ldap_name != u.username
        puts "- username: #{u.username}\t<=>\tldapname: #{u.ldap_name}"
        count += 1
      end
    end

    if count == 0
      puts "None. Doing nothing..."
      exit 0
    end

    print "Are you sure that you want to proceed with this ? (y/N) "
    opt = $stdin.gets.strip
    exit 0 if opt != "y" && opt != "Y" && opt != "yes"

    ActiveRecord::Base.transaction do
      User.all.find_each do |u|
        if !u.ldap_name.blank? && u.ldap_name != u.username
          u.update_attributes!(username: u.ldap_name)
        end
      end
    end
  end

  desc "Properly test Portus"
  task :test do |_, args|
    tags = args.extras.map { |a| "--tag #{a}" }
    tags << "--tag ~integration" if ENV["TRAVIS"] == "true"

    # Run normal tests + integration.
    ENV["INTEGRATION_LDAP"] = nil
    status = spawn_cmd("rspec spec #{tags.join(" ")}")
    exit(status) if status != 0
    exit(0) if ENV["TRAVIS"] == "true"

    # Run LDAP integration tests.
    ENV["INTEGRATION_LDAP"] = "t"
    tags << "--tag integration" unless args.extras.include?("integration")
    status = spawn_cmd("rspec spec #{tags.join(" ")}")
    exit(status)
  end
end
