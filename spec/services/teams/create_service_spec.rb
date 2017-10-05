require "rails_helper"

describe "Teams::CreateService" do
  let!(:user) { create(:user) }

  describe "#execute" do
    context "with params" do
      subject(:service) { Teams::CreateService.new(user, name: "name") }

      it "creates a new team" do
        expect { service.execute }.to change(Team, :count).by(1)
      end

      it "creates a new activity" do
        expect { service.execute }.to change(PublicActivity::Activity, :count).by(1)
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
