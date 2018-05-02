# frozen_string_literal: true

require "rails_helper"

describe WebhookPolicy do
  subject { described_class }

  let(:user)        { create(:user) }
  let(:owner)       { create(:user) }
  let(:viewer)      { create(:user) }
  let(:contributor) { create(:user) }
  let(:team) do
    create(:team,
           owners:       [owner],
           contributors: [contributor],
           viewers:      [viewer])
  end
  let(:namespace) do
    create(
      :namespace,
      description: "short test description.",
      registry:    @registry,
      team:        team
    )
  end
  let(:webhook) { create(:webhook, namespace: namespace) }

  before do
    @admin = create(:admin)
    @registry = create(:registry)
  end

  context "owners can also create or update" do
    permissions :create? do
      it "allows an admin to create a webook" do
        expect(subject).to permit(@admin, webhook)
      end

      it "allows an admin to create a webhook" do
        expect(subject).to permit(owner, webhook)
      end
    end

    permissions :update? do
      it "allows an admin to update a webook" do
        expect(subject).to permit(@admin, webhook)
      end

      it "allows an admin to update a webhook" do
        expect(subject).to permit(owner, webhook)
      end
    end
  end

  context "only admins can create or update" do
    before do
      APP_CONFIG["user_permission"]["create_webhook"] = false
      APP_CONFIG["user_permission"]["manage_webhook"] = false
    end

    permissions :create? do
      it "allows an admin to create a webook" do
        expect(subject).to permit(@admin, webhook)
      end

      it "does not allow an admin to create a webhook" do
        expect(subject).not_to permit(owner, webhook)
      end
    end

    permissions :update? do
      it "allows an admin to update a webook" do
        expect(subject).to permit(@admin, webhook)
      end

      it "does not allow an admin to update a webhook" do
        expect(subject).not_to permit(owner, webhook)
      end
    end
  end

  permissions :toggle_enabled? do
    it "allows admin to change it" do
      expect(subject).to permit(@admin, webhook)
    end

    it "allows owner to change it" do
      expect(subject).to permit(owner, webhook)
    end

    it "disallows contributor to change it" do
      expect(subject).not_to permit(contributor, webhook)
    end

    it "disallows user to change it" do
      expect(subject).not_to permit(user, webhook)
    end

    it "disallows viewer to change it" do
      expect(subject).not_to permit(viewer, webhook)
    end
  end

  describe "scope" do
    before do
      webhook
    end

    it "shows all webhooks" do
      expected = Webhook.all
      expect(Pundit.policy_scope(@admin, Webhook).to_a).to match_array(expected)
    end

    it "shows webhooks to owner" do
      expected = webhook
      expect(Pundit.policy_scope(owner, Webhook).to_a).to match_array(expected)
    end

    it "shows webhooks to contributor" do
      expected = webhook
      expect(Pundit.policy_scope(contributor, Webhook).to_a).to match_array(expected)
    end

    it "shows webhooks to viewer" do
      expected = webhook
      expect(Pundit.policy_scope(viewer, Webhook).to_a).to match_array(expected)
    end

    it "does show webhooks to user when appropiate" do
      expect(Pundit.policy_scope(user, Webhook).to_a).to be_empty
      create(:webhook, namespace: user.namespace)
      expect(Pundit.policy_scope(user, Webhook).to_a).not_to be_empty
    end
  end
end
