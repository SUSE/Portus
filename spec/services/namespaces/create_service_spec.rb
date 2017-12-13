# frozen_string_literal: true

require "rails_helper"

describe "Namespaces::CreateService" do
  let!(:user) { create(:user) }
  let!(:team) { create(:team, owners: [user]) }
  let!(:registry) { create(:registry) }
  let!(:namespace) do
    Namespaces::BuildService.new(user, name: "name", team: team.name).execute
  end

  describe "#execute" do
    context "with namespace" do
      subject(:service) { Namespaces::CreateService.new(user, namespace) }

      it "creates a new namespace" do
        expect { service.execute }.to change(Namespace, :count).by(1)
      end

      it "creates a new activity" do
        expect { service.execute }.to change(PublicActivity::Activity, :count).by(1)
      end
    end

    context "without namespace" do
      subject(:service) { Namespaces::CreateService.new(user) }

      it "does not creates a new namespace" do
        expect { service.execute }.to change(Namespace, :count).by(0)
      end

      it "does not creates a new activity" do
        expect { service.execute }.to change(PublicActivity::Activity, :count).by(0)
      end
    end
  end
end
