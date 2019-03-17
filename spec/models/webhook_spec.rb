# frozen_string_literal: true

# == Schema Information
#
# Table name: webhooks
#
#  id             :integer          not null, primary key
#  namespace_id   :integer
#  url            :string(255)
#  username       :string(255)
#  password       :string(255)
#  request_method :integer
#  content_type   :integer
#  enabled        :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  name           :string(255)      not null
#
# Indexes
#
#  index_webhooks_on_namespace_id  (namespace_id)
#

require "rails_helper"

RSpec.describe Webhook, type: :model do
  subject { create(:webhook, namespace: create(:namespace)) }

  let!(:request_methods) { %w[GET POST] }
  let!(:content_types) { ["application/json", "application/x-www-form-urlencoded"] }

  it { is_expected.to have_many(:headers) }
  it { is_expected.to have_many(:deliveries) }
  it { is_expected.to belong_to(:namespace) }

  it { is_expected.to allow_value("example.org").for(:url) }
  it { is_expected.not_to allow_value("won't work").for(:url) }
  it { is_expected.not_to allow_value("ftp:///home/mssola").for(:url) }

  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to define_enum_for(:request_method) }
  it { is_expected.to allow_value(*request_methods).for(:request_method) }
  it { is_expected.to define_enum_for(:content_type) }
  it { is_expected.to allow_value(*content_types).for(:content_type) }

  describe "push and delete events" do
    let!(:registry)  { create(:registry) }
    let!(:owner)     { create(:user) }
    let!(:team)      { create(:team, owners: [owner]) }
    let!(:namespace) { create(:namespace, team: team, registry: registry) }
    let!(:repo)      { create(:repository, namespace: namespace) }
    let!(:event) do
      {
        "request" => { "host" => registry.hostname.to_s },
        "target"  => { "repository" => "#{namespace.name}/#{repo.name}" }
      }
    end

    before do
      stub_request(:POST, "username:password@www.example.com")
        .to_return(status: 200)
      stub_request(:POST, "www.example.com").to_return(status: 200)
    end

    context "triggering a webhook" do
      let!(:webhook_noauth) { create(:webhook, namespace: namespace) }
      let!(:webhook_auth) do
        create(:webhook, namespace: namespace, username: "username", password: "password")
      end
      let!(:webhook_header) do
        create(:webhook_header, webhook: webhook_auth, name: "foo", value: "bar")
      end

      it "works when given user credentials" do
        Webhook.handle_push_event(event)
        delivery = WebhookDelivery.find_by(webhook: webhook_auth)
        expect(delivery.status).to eq 200
        expect(JSON.parse(delivery.request_body)).to eq event

        Webhook.handle_delete_event(event)
        delivery = WebhookDelivery.find_by(webhook: webhook_auth)
        expect(delivery.status).to eq 200
        expect(JSON.parse(delivery.request_body)).to eq event
      end

      it "works when providing no user credentials" do
        Webhook.handle_push_event(event)
        delivery = WebhookDelivery.find_by(webhook: webhook_noauth)
        expect(delivery.status).to eq 200
        expect(JSON.parse(delivery.request_body)).to eq event

        Webhook.handle_delete_event(event)
        delivery = WebhookDelivery.find_by(webhook: webhook_noauth)
        expect(delivery.status).to eq 200
        expect(JSON.parse(delivery.request_body)).to eq event
      end

      it "fails in the given namespace cannot be found" do
        event["target"]["repository"] = "unknown_namespace/unknown_repo"
        expect(Webhook.handle_push_event(event)).to be nil
        expect(Webhook.handle_delete_event(event)).to be nil
      end
    end

    it "skips disabled webhooks" do
      Webhook.handle_push_event(event)
      expect(WebhookDelivery.all).to be_empty

      Webhook.handle_delete_event(event)
      expect(WebhookDelivery.all).to be_empty
    end
  end
end
