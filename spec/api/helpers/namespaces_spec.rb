# frozen_string_literal: true

require "rails_helper"

RSpec.describe ::API::Helpers::Namespaces, type: :helper do
  let!(:registry)  { create(:registry) }
  let!(:user)      { create(:admin) }
  let!(:loser)     { create(:user) }
  let!(:team)      { create(:team, owners: [user]) }
  let!(:namespace) { create(:namespace, team: team, registry: registry) }

  describe "can_destroy_namespace?" do
    before do
      APP_CONFIG["delete"]["enabled"] = true
    end

    it "can destroy a namespace with the right authorization" do
      expect(can_destroy_namespace?(namespace, user)).to be_truthy
    end

    it "cannot destroy a namespace without authorization" do
      expect(can_destroy_namespace?(namespace, loser)).to be_falsey
    end

    it "cannot destroy a personal namespace" do
      expect(can_destroy_namespace?(user.namespace, user)).to be_falsey
    end
  end
end
