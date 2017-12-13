# frozen_string_literal: true

require "rails_helper"

describe "Webhooks support" do
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
    it "A user cannot create an empty webhook", js: true do
      webhooks_count = namespace.webhooks.count

      visit namespace_webhooks_path(namespace)
      find("#add_webhook_btn").click

      click_button "Create"
      wait_for_ajax

      expect(namespace.webhooks.count).to eql webhooks_count
      expect(page).to have_current_path(namespace_webhooks_path(namespace))
    end

    it "A user can create a webhook from namespace's webhooks page", js: true do
      webhooks_count = namespace.webhooks.count

      visit namespace_webhooks_path(namespace)
      find("#add_webhook_btn").click
      wait_for_effect_on("#add_webhook_form")

      fill_in "Url", with: "url-here"
      click_button "Create"

      wait_for_ajax
      wait_for_effect_on("#float-alert")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Webhook 'url-here' has been created successfully")

      # Check that it created a link to it and that it's accessible.
      expect(namespace.webhooks.count).to eql webhooks_count + 1
      expect(page).to have_link("http://url-here")
      find(:link, "http://url-here").trigger(:click)

      webhook = namespace.webhooks.find_by(url: "http://url-here")
      expect(page).to have_current_path(namespace_webhook_path(namespace, webhook))
    end

    it 'The "Create new webhook" link has a toggle effect', js: true do
      visit namespace_webhooks_path(namespace)

      expect(page).to have_css("#add_webhook_btn i.fa-plus-circle")
      expect(page).not_to have_css("#add_webhook_btn i.fa-minus-circle")

      find("#add_webhook_btn").click

      expect(page).not_to have_css("#add_webhook_btn i.fa-plus-circle")
      expect(page).to have_css("#add_webhook_btn i.fa-minus-circle")

      find("#add_webhook_btn").click

      expect(page).to have_css("#add_webhook_btn i.fa-plus-circle")
      expect(page).not_to have_css("#add_webhook_btn i.fa-minus-circle")
    end

    it "A user enables/disables webhook", js: true do
      visit namespace_webhooks_path(namespace)
      id = webhook.id

      expect(page).to have_css("#webhook_#{id} .fa-toggle-on")
      find("#webhook_#{id} .toggle").click
      wait_for_ajax

      expect(page).to have_css("#webhook_#{id} .fa-toggle-off")
      expect(page).to have_content("Webhook '#{webhook.url}' is now disabled")

      find("#webhook_#{id} .toggle").click
      wait_for_ajax

      expect(page).to have_css("#webhook_#{id} .fa-toggle-on")
      expect(page).to have_content("Webhook '#{webhook.url}' is now enabled")
    end

    it "A user deletes a webhook", js: true do
      visit namespace_webhooks_path(namespace)
      id = webhook.id

      expect(page).to have_link(webhook.url)

      find("#webhook_#{id} .delete-webhook-btn").click
      find(".popover-content .btn-primary").click
      wait_for_ajax

      expect(page).not_to have_link(webhook.url)
      expect(page).to have_content("Webhook '#{webhook.host}' has been removed successfully")
    end
  end

  describe "#show" do
    it "A user updates webhooks info", js: true do
      visit namespace_webhook_path(namespace, webhook)

      find(".edit-webhook-link").click
      fill_in "webhook_url", with: "http://new-webhook-url"
      fill_in "Username", with: "new-username"
      fill_in "Password", with: "password"
      click_button "Save"
      wait_for_ajax

      expect(page).to have_content("new-webhook-url webhook")
      expect(page).to have_content("new-username")
      expect(page).to have_content("***********")
      expect(page).to have_content("Webhook 'new-webhook-url' has been updated successfully")
    end

    it 'The "Edit webhook" link has a toggle effect', js: true do
      visit namespace_webhook_path(namespace, webhook)

      expect(page).to have_css(".edit-webhook-link .fa-pencil")
      expect(page).not_to have_css(".edit-webhook-link .fa-close")

      find(".edit-webhook-link").click

      expect(page).not_to have_css(".edit-webhook-link .fa-pencil")
      expect(page).to have_css(".edit-webhook-link .fa-close")

      find(".edit-webhook-link").click

      expect(page).to have_css(".edit-webhook-link .fa-pencil")
      expect(page).not_to have_css(".edit-webhook-link .fa-close")
    end

    describe "webhook_header" do
      it "A user can create a header from webhook's page", js: true do
        webhook_headers_count = webhook.headers.count

        visit namespace_webhook_path(namespace, webhook)

        find("#add_webhook_header_btn").click
        wait_for_effect_on("#add_webhook_header_form")

        fill_in "Name", with: "cool-header"
        fill_in "Value", with: "cool-value"
        click_button "Create"

        wait_for_ajax
        wait_for_effect_on("#float-alert")

        expect(page).to have_css("#float-alert")
        expect(page).to have_content("cool-header")
        expect(page).to have_content("cool-value")
        expect(page).to have_content("Header 'cool-header' was created successfully")
        expect(webhook.headers.count).to eql webhook_headers_count + 1
      end

      it "A user cannot create a header that already exists", js: true do
        webhook_headers_count = webhook.headers.count

        visit namespace_webhook_path(namespace, webhook)
        find("#add_webhook_header_btn").click
        wait_for_effect_on("#add_webhook_header_form")

        expect(focused_element_id).to eq "webhook_header_name"
        fill_in "Name", with: webhook_header.name
        fill_in "Value", with: "something"
        click_button "Create"

        wait_for_ajax
        wait_for_effect_on("#float-alert")

        expect(page).to have_css("#float-alert")
        expect(page).to have_content("Name has already been taken")
        expect(webhook.headers.count).to eql webhook_headers_count
      end

      it "A user deletes a webhook header", js: true do
        visit namespace_webhook_path(namespace, webhook)
        id = webhook_header.id

        expect(page).to have_content(webhook_header.name)
        expect(page).to have_content(webhook_header.value)

        find("#webhook_header_#{id} .delete-webhook-header-btn").click
        find(".popover-content .btn-primary").click

        wait_for_ajax
        wait_for_effect_on("#float-alert")

        expect(page).to have_css("#float-alert")
        expect(page).to have_content("Header '#{webhook_header.name}' was removed successfully")
        expect(page).not_to have_content(webhook_header.name)
        expect(page).not_to have_content(webhook_header.value)
      end

      it 'The "Create new header" link has a toggle effect', js: true do
        visit namespace_webhook_path(namespace, webhook)

        expect(page).to have_css("#add_webhook_header_btn i.fa-plus-circle")
        expect(page).not_to have_css("#add_webhook_header_btn i.fa-minus-circle")

        find("#add_webhook_header_btn").click

        expect(page).not_to have_css("#add_webhook_header_btn i.fa-plus-circle")
        expect(page).to have_css("#add_webhook_header_btn i.fa-minus-circle")

        find("#add_webhook_header_btn").click

        expect(page).to have_css("#add_webhook_header_btn i.fa-plus-circle")
        expect(page).not_to have_css("#add_webhook_header_btn i.fa-minus-circle")
      end
    end
  end
end
