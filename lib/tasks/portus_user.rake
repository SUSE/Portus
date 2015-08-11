namespace :portus do
  desc 'It tries to create the "portus" user on an existing DB'
  task create: :environment do
    User.create!(
      username: "portus",
      password: Rails.application.secrets.portus_password,
      email:    "portus@portus.com",
      admin:    true
    )
  end
end
