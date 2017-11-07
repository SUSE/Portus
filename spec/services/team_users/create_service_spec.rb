# frozen_string_literal: true

require "rails_helper"

describe "TeamUsers::CreateService" do
  let!(:user) { create(:user) }
  let!(:owner) { create(:user) }
  let!(:team) { create(:team, owners: [owner]) }
  let!(:team_user) do
    TeamUsers::BuildService.new(user, id: team.id, user: user.username, role: "viewer").execute
  end

  describe "#execute" do
    context "with team user" do
      subject(:service) { TeamUsers::CreateService.new(user, team_user) }

      it "creates a new team user" do
        expect { service.execute }.to change(TeamUser, :count).by(1)
      end

      it "creates a new activity" do
        expect { service.execute }.to change(PublicActivity::Activity, :count).by(1)
      end
    end

    context "without team user" do
      subject(:service) { TeamUsers::CreateService.new(user) }

      it "does not creates a new team user" do
        expect { service.execute }.to change(TeamUser, :count).by(0)
      end

      it "does not creates a new activity" do
        expect { service.execute }.to change(PublicActivity::Activity, :count).by(0)
      end
    end
  end
end
