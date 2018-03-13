# frozen_string_literal: true

require_relative "shared"

clean_db!
create_registry!

User.create!(
  username: "admin",
  password: "12341234",
  email:    "admin@example.local",
  admin:    true
)
