namespace :portus do
  task :set_admin, [:username] => [:environment] do |_, args|
    unless args[:username]
      puts "Specify a username, as in"
      puts " rake portus:set_admin[username]"
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
