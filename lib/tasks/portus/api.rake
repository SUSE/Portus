# frozen_string_literal: true

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
end
