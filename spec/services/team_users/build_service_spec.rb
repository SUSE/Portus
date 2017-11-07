# frozen_string_literal: true

require "rails_helper"

describe "TeamUsers::BuildService" do
  let!(:user) { create(:user) }
  let!(:team) { create(:team, owners: [user]) }

  describe "#execute" do
    context "with valid params" do
      it "builds a new team user object" do
        service = TeamUsers::BuildService.new(user, role: "viewer", id: team.id,
                                              user: user.username)

        team_user = service.execute

        expect(team_user.persisted?).to be_falsey
      end

      it "always enforce portus admin role to owner" do
        admin = create(:admin)
        service = TeamUsers::BuildService.new(user, role: "viewer", id: team.id,
                                              user: admin.username)

        team_user = service.execute

        expect(team_user.persisted?).to be_falsey
        expect(team_user.role).to eq("owner")
      end
    end

    context "with invalid team" do
      it "raises record not found exception if team does not exist" do
        service = TeamUsers::BuildService.new(user, role: "viewer", id: "team",
                                              user: user.username)

        expect { service.execute }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises record not found exception if user does not exist" do
        service = TeamUsers::BuildService.new(user, role: "viewer", id: team.id, user: "user")

        expect { service.execute }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "without params" do
      subject(:service) { TeamUsers::BuildService.new(user) }

      it "does not build a team user object" do
        expect(service.execute).to be_nil
      end
    end
  end
end
