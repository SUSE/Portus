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

end
