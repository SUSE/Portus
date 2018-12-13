# frozen_string_literal: true

require "rails_helper"

describe "Teams::DestroyService" do
  let!(:registry)   { create(:registry, hostname: "registry.test.lan") }
  let!(:user)       { create(:admin) }
  let!(:team)       { create(:team, owners: [user]) }
  let!(:new_team)   { create(:team, owners: [user]) }
  let!(:namespace)  { create(:namespace, team: team, registry: registry) }

  subject(:service) { ::Teams::DestroyService.new(user) }

  context "with params" do
    before do
      allow_any_instance_of(::Namespaces::DestroyService).to(receive(:execute).and_return(true))
      allow_any_instance_of(::Teams::MigrationService).to(receive(:execute).and_return(true))
    end

    it "destroys team" do
      expect { service.execute(team) }.to change(Team, :count).by(-1)
    end

    it "destroys team namespaces" do
      expect { service.execute(team, true) }.to change(Namespace, :count).by(-1)
    end

    it "creates a new activity" do
      expect { service.execute(team) }.to change(PublicActivity::Activity, :count).by(1)
    end

    it "stores the error on delete" do
      allow_any_instance_of(Team).to(receive(:delete_by!).and_return(false))
      service.execute(team)
      expect(service.error).to eq "Could not remove team"
    end

    it "stores the errors on namespaces that failed to be removed" do
      allow_any_instance_of(::Namespaces::DestroyService).to(receive(:execute).and_return(false))
      allow_any_instance_of(::Namespaces::DestroyService).to(
        receive(:error).and_return("I AM ERROR")
      )

      expect { service.execute(team, nil) }.not_to change(Team, :count)
      expect(service.error.size).to eq 1
      expect(service.error[namespace.name]).to eq "I AM ERROR"
    end

    it "stores the errors of team that failed to be migrated" do
      allow_any_instance_of(::Teams::MigrationService).to(receive(:execute).and_return(false))
      allow_any_instance_of(::Teams::MigrationService).to(
        receive(:error).and_return("I AM ERROR")
      )

      expect { service.execute(team, new_team) }.not_to change(Team, :count)
      expect(service.error).to eq "I AM ERROR"
    end
  end

  context "without params" do
    it "raises RecordNotFound exception" do
      expect { service.execute(nil) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
