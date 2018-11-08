# frozen_string_literal: true

require "rails_helper"

describe "Webhooks support", type: :system, js: true do
  let!(:registry) { create(:registry) }
  let!(:user) { create(:admin) }
  let!(:user2) { create(:user) }
  let!(:user3) { create(:user) }
  let!(:team) { create(:team, owners: [user], contributors: [user2], viewers: [user3]) }
  let!(:namespace) { create(:namespace, team: team, registry: registry) }
  let!(:webhook) { create(:webhook, namespace: namespace) }
  let!(:webhook_header) do
    create(:webhook_header,
           name:    "h-name",
           value:   "h-value",
           webhook: webhook)
  end

  before do
    login_as user, scope: :user
  end

  describe "#index" do
    before do
      visit namespace_webhooks_path(namespace)
    end

    it "A user cannot create an empty webhook" do
      find(".toggle-link-new-webhook").click

      expect(page).to have_button("Add", disabled: true)
    end

    it "A user can create a webhook from namespace's webhooks page" do
      webhooks_count = namespace.webhooks.count

      find(".toggle-link-new-webhook").click

      fill_in "Name", with: "webhook name"
      fill_in "URL", with: "http://url-here"
      click_button "Add"

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Webhook 'webhook name' was created successfully")

      # Check that it created a link to it and that it's accessible.
      expect(namespace.webhooks.count).to eql webhooks_count + 1
      expect(page).to have_link("webhook name")
      find(:link, "webhook name").click

      webhook = namespace.webhooks.find_by(url: "http://url-here")
      expect(page).to have_current_path(namespace_webhook_path(namespace, webhook))
    end

    it "A user enables/disables webhook" do
      id = webhook.id

      expect(page).to have_css(".webhook_#{id} .fa-toggle-on")
      find(".webhook_#{id} .toggle").click

      expect(page).to have_css(".webhook_#{id} .fa-toggle-off")
      expect(page).to have_content("Webhook '#{webhook.name}' is now disabled")

      find(".webhook_#{id} .toggle").click

      expect(page).to have_css(".webhook_#{id} .fa-toggle-on")
      expect(page).to have_content("Webhook '#{webhook.name}' is now enabled")
    end

    it "A user deletes a webhook" do
      expect(page).to have_link(webhook.name)

      click_confirm_popover(".webhook_#{webhook.id} .delete-webhook-btn")

      expect(page).not_to have_link(webhook.name)
      expect(page).to have_content("Webhook '#{webhook.name}' was removed successfully")
    end
  end

  describe "#show" do
    before do
      visit namespace_webhook_path(namespace, webhook)
    end

    it "cannot update webhook if form is invalid" do
      find(".toggle-link-edit-webhook").click
      clear_field("#webhook_name")

      expect(page).to have_content("Name can't be blank")
      expect(page).to have_button("Save", disabled: true)
    end

    it "A user updates webhooks info" do
      find(".toggle-link-edit-webhook").click
      fill_in "Name", with: "new_name"
      fill_in "webhook_url", with: "http://new-webhook-url"
      fill_in "Username", with: "new-username"
      fill_in "Password", with: "password"
      click_button "Save"

      expect(page).to have_content("new_name webhook")
      expect(page).to have_content("new-webhook-url")
      expect(page).to have_content("new-username")
      expect(page).to have_content("********")
      expect(page).to have_content("Webhook 'new_name' was updated successfully")
    end

    describe "webhook_header" do
      it "A user can create a header from webhook's page" do
        webhook_headers_count = webhook.headers.count

        find(".toggle-link-new-webhook-header").click

        fill_in "Name", with: "cool-header"
        fill_in "Value", with: "cool-value"
        click_button "Add"

        expect(page).to have_css("#float-alert")
        expect(page).to have_content("cool-header")
        expect(page).to have_content("cool-value")
        expect(page).to have_content("Header 'cool-header' was created successfully")
        expect(webhook.headers.count).to eql webhook_headers_count + 1
      end

      it "A user cannot create a header that already exists" do
        webhook_headers_count = webhook.headers.count

        find(".toggle-link-new-webhook-header").click

        expect(focused_element_id).to eq "header_name"
        fill_in "Name", with: webhook_header.name
        fill_in "Value", with: "something"
        click_button "Add"

        expect(page).to have_css("#float-alert")
        expect(page).to have_content("Name has already been taken")
        expect(webhook.headers.count).to eql webhook_headers_count
      end

      it "A user deletes a webhook header" do
        expect(page).to have_content(webhook_header.name)
        expect(page).to have_content(webhook_header.value)

        click_confirm_popover(".webhook_header_#{webhook_header.id} .delete-webhook-header-btn")

        expect(page).to have_css("#float-alert")
        expect(page).to have_content("Header '#{webhook_header.name}' was removed successfully")
        expect(page).not_to have_content(webhook_header.value)
      end
    end
  end
end
