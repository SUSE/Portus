
# frozen_string_literal: true

# A simple module containing some helper methods for acceptance tests.
module Helpers
  # Login the given user and visit the root url.
  def login(user)
    login_as user, scope: :user
    visit root_url
  end

  # Returns a String containing the id of the currently active element.
  def focused_element_id
    page.evaluate_script("document.activeElement.id")
  end

  def enable_security_vulns_module!
    APP_CONFIG["security"]["dummy"] = {
      "server" => "dummy"
    }
  end

  def build_token_header(token)
    {
      "PORTUS-AUTH" => "#{token.user.username}:#{token.application}"
    }
  end

  # Clears a field value. `fill_in` also does the job but
  # it doesn't trigger keyUp event, for example
  def clear_field(field)
    find_field(field).send_keys([:control, "a"], :backspace)
  end
end

RSpec.configure { |config| config.include Helpers }
