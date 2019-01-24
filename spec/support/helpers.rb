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
    find(field).native.send_keys([:control, "a"], :backspace)
  end

  # Unfortunately vue-multiselect component is not very friendly regarding
  # interactions without being in the vue/node testing world.
  def fill_vue_multiselect(element, text)
    execute_script("document.querySelector('#{element}').dispatchEvent(new Event('focus'))")
    execute_script("document.querySelector('#{element} .multiselect__input').value = '#{text}'")
    execute_script("document.querySelector('#{element} .multiselect__input')
                    .dispatchEvent(new Event('input'))")
  end

  def deselect_vue_multiselect(element, text)
    fill_vue_multiselect(element, text)
    expect(page).to have_css("#{element} .multiselect__option--selected")
    execute_script("document.querySelector('#{element} .multiselect__option--selected')
                    .dispatchEvent(new Event('click'))")
  end

  def select_vue_multiselect(element, text)
    fill_vue_multiselect(element, text)
    expect(page).to have_css("#{element} .multiselect__option--highlight")
    execute_script("document.querySelector('#{element} .multiselect__option--highlight')
                    .dispatchEvent(new Event('click'))")
  end

  def click_confirm_popover(element)
    expect(page).to have_css(element)
    find(element).click
    find(".popover-content .yes").click
  end

  def toggle_new_namespace_form
    find(".toggle-link-new-namespace").click
  end

  def toggle_edit_namespace_form
    find(".toggle-link-edit-namespace").click
  end

  def toggle_edit_team_form
    find(".toggle-link-edit-team").click
  end

  def toggle_new_team_form
    find(".toggle-link-new-team").click
  end

  def toggle_new_member_form
    find(".toggle-link-new-member").click
  end

  def toggle_namespace_transfer_modal
    find(".toggle-transfer-modal").click
  end

  def toggle_team_delete_modal
    find(".toggle-delete-modal").click
  end

  def toggle_user_deletion_modal
    find(".toggle-deletion-modal").click
  end
end

RSpec.configure { |config| config.include Helpers }
