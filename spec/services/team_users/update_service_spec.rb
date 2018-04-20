# frozen_string_literal: true

require "rails_helper"

describe "TeamUsers::UpdateService" do
  let!(:user) { create(:user) }
  let!(:admin) { create(:admin) }
  let!(:owner) { create(:user) }
  let!(:contributor) { create(:user) }
  let!(:team) { create(:team, owners: [owner], contributors: [contributor]) }

  describe "#execute" do
    context "with params" do
      subject(:service) { TeamUsers::UpdateService.new(user, role: "viewer") }

      it "updates team user" do
        tu_contrib = team.team_users.last

        service.execute(tu_contrib)

        expect(tu_contrib.role).to eq("viewer")
      end

      it "creates a new activity" do
        tu_contrib = team.team_users.last

        expect { service.execute(tu_contrib) }.to change(PublicActivity::Activity, :count).by(1)
      end

      it "doesn't demote owner if it's the only owner" do
        tu_owner = team.team_users.first

        expect { service.execute(tu_owner) }.to change(TeamUser, :count).by(0)
      end

      it "doesn't demote portus admin" do
        team = create(:team, owners: [admin, owner], contributors: [contributor])
        tu_admin = team.team_users.first

        expect { service.execute(tu_admin) }.to change(TeamUser, :count).by(0)
      end

      it "doesn't create activity if it's the only owner" do
        tu_owner = team.team_users.first

        expect { service.execute(tu_owner) }.to change(PublicActivity::Activity, :count).by(0)
      end

      it "doesn't create activity if it's demoting admin" do
        team = create(:team, owners: [admin, owner], contributors: [contributor])
        tu_admin = team.team_users.first

        expect { service.execute(tu_admin) }.to change(PublicActivity::Activity, :count).by(0)
      end
    end

    context "without params" do
      subject(:service) { TeamUsers::UpdateService.new(user) }

      it "returns false" do
        expect(service.execute(nil)).to be_falsey
      end

      it "doesn't creates a new activity" do
        expect { service.execute(nil) }.to change(PublicActivity::Activity, :count).by(0)
      end
    end
  end
end
