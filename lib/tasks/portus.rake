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

    User.create!(
      username: args["username"],
      password: args["password"],
      email:    args["email"],
      admin:    args["admin"]
    )
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
    tags = update ? Tag.all : Tag.where(digest: "")

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
      digest = client.manifest(t.repository.name, t.name, true)
      t.update_attributes(digest: digest)
    end
    puts
  end
end
