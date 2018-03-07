# frozen_string_literal: true

require_relative "shared"

clean_db!
create_registry!

admin = User.create!(
  username: "admin",
  password: "12341234",
  email:    "admin@example.local",
  admin:    true
)

contributor = User.create!(
  username: "user",
  password: "12341234",
  email:    "user@example.local",
  admin:    false
)

viewer = User.create!(
  username: "viewer",
  password: "12341234",
  email:    "viewer@example.local",
  admin:    false
)

t = Team.create!(name: "team", owners: [admin], contributors: [contributor], viewers: [viewer])
Namespace.create!(name: "namespace", team: t, registry: Registry.get)
