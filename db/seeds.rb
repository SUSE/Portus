if ENV['INTEGRATION_TESTS']
  puts 'Adding user username31'
  if User.find_by_username('username31')
    puts 'User already exists. Please drop the database first'
    exit(-1)
  end

  User.create(
    username: 'username31',
    email: 'a1@b.com',
    password: 'test-password',
    admin: true
  )

  puts 'Adding registry portus.suse.example.com:5000'
  Registry.create(
    name: 'portus.suse.example.com:5000',
    hostname: 'portus.suse.example.com:5000'
  )
end
