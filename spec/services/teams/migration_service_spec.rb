# frozen_string_literal: true

require "rails_helper"

describe "Teams::MigrationService" do
  let!(:registry)   { create(:registry, hostname: "registry.test.lan") }
  let!(:user)       { create(:admin) }
  let!(:team)       { create(:team, owners: [user]) }
  let!(:new_team)   { create(:team, owners: [user]) }
  let!(:namespace)  { create(:namespace, team: team, registry: registry) }

  subject(:service) { ::Teams::MigrationService.new(user) }

  context "with params" do
    it "migrates namespaces" do
      expect { service.execute(team, new_team) }.to change(team.namespaces, :count).by(-1)
      expect { service.execute(new_team, team) }.to change(team.namespaces, :count).by(1)
    end

    it "ignores if namespaces are empty" do
      expect { service.execute(new_team, team) }.to change(team.namespaces, :count).by(0)
    end

    it "creates a new activity" do
      expect { service.execute(team, new_team) }.to change(PublicActivity::Activity, :count).by(1)
    end

    it "stores the error on update failed" do
      allow(team.namespaces).to(receive(:update_all).and_return(false))
      service.execute(team, new_team)
      expect(service.error).to eq "Could not migrate namespaces"
    end

    it "stores the error if same team" do
      service.execute(team, team)
      expect(service.error).to eq "You cannot choose the same team to migrate namespaces"
    end
  end

  context "without params" do
    it "raises RecordNotFound exception" do
      expect { service.execute(nil, nil) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { service.execute(team, nil) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
