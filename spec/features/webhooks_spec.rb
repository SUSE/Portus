require "rails_helper"

feature "Webhooks support" do
  let!(:registry) { create(:registry) }
  let!(:user) { create(:admin) }
  let!(:user2) { create(:user) }
  let!(:user3) { create(:user) }
  let!(:team) { create(:team, owners: [user], contributors: [user2], viewers: [user3]) }
  let!(:namespace) { create(:namespace, team: team, registry: registry) }
  let!(:webhook) { create(:webhook, namespace: namespace) }

  before do
    login_as user, scope: :user
  end

  describe "#index" do
    scenario "A user cannot create an empty webhook", js: true do
      webhooks_count = namespace.webhooks.count

      visit namespace_webhooks_path(namespace)
      find("#add_webhook_btn").click

      click_button "Create"
      wait_for_ajax

      expect(namespace.webhooks.count).to eql webhooks_count
      expect(page).to have_current_path(namespace_webhooks_path(namespace))
    end

    scenario "A user can create a webhook from namespace's webhooks page", js: true do
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

    scenario 'The "Create new webhook" link has a toggle effect', js: true do
      visit namespace_webhooks_path(namespace)

      expect(page).to have_css("#add_webhook_btn i.fa-plus-circle")
      expect(page).to_not have_css("#add_webhook_btn i.fa-minus-circle")

      find("#add_webhook_btn").click

      expect(page).to_not have_css("#add_webhook_btn i.fa-plus-circle")
      expect(page).to have_css("#add_webhook_btn i.fa-minus-circle")

      find("#add_webhook_btn").click

      expect(page).to have_css("#add_webhook_btn i.fa-plus-circle")
      expect(page).to_not have_css("#add_webhook_btn i.fa-minus-circle")
    end

    scenario "A user enables/disables webhook", js: true do
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

    scenario "A user deletes a webhook", js: true do
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
    scenario "A user updates webhooks info", js: true do
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

    scenario 'The "Edit webhook" link has a toggle effect', js: true do
      visit namespace_webhook_path(namespace, webhook)

      expect(page).to have_css(".edit-webhook-link .fa-pencil")
      expect(page).to_not have_css(".edit-webhook-link .fa-close")

      find(".edit-webhook-link").click

      expect(page).not_to have_css(".edit-webhook-link .fa-pencil")
      expect(page).to have_css(".edit-webhook-link .fa-close")

      find(".edit-webhook-link").click

      expect(page).to have_css(".edit-webhook-link .fa-pencil")
      expect(page).to_not have_css(".edit-webhook-link .fa-close")
    end
  end
end
