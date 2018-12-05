# frozen_string_literal: true

# This file updates the password of the portus hidden user if this
# exists and the secret is given.

portus_exists = false
begin
  portus_exists = User.exists?(username: "portus")
rescue StandardError
  # We will ignore any error and skip this initializer. This is done this way
  # because it can get really tricky to catch all the myriad of exceptions that
  # might be raised on database errors.
  portus_exists = false
end

password = Rails.application.secrets.portus_password
if portus_exists && password.present?
  portus = User.portus
  portus&.update_attribute("password", Rails.application.secrets.portus_password)
end
