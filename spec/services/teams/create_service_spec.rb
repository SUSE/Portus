# frozen_string_literal: true

require "rails_helper"

describe "Teams::CreateService" do
  let!(:admin) { create(:admin) }
  let!(:user) { create(:user) }
  let!(:new_owner) { create(:user) }

  describe "#execute" do
    context "with params current user as owner" do
      subject(:service) { Teams::CreateService.new(admin, name: "name") }

      it "creates a new team" do
        expect { service.execute }.to change(Team, :count).by(1)
      end

      it "creates a new activity" do
        expect { service.execute }.to change(PublicActivity::Activity, :count).by(1)
      end
    end

    context "with params other user as owner" do
      subject(:service) { Teams::CreateService.new(admin, name: "name", owner_id: new_owner.id) }
      subject(:service2) { Teams::CreateService.new(user, name: "name", owner_id: new_owner.id) }

      it "creates a new team " do
        team = service.execute
        expect(team.owners).to include(new_owner)
      end

      it "raises not authorized exception if current user is not an admin" do
        expect { service2.execute }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "without params" do
      subject(:service) { Teams::CreateService.new(user) }

      it "creates a new team" do
        expect { service.execute }.to change(Team, :count).by(0)
      end

      it "creates a new activity" do
        expect { service.execute }.to change(PublicActivity::Activity, :count).by(0)
      end
    end
  end
end
