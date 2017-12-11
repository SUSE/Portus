# frozen_string_literal: true

require "rails_helper"

describe "Namespaces::CreateService" do
  let!(:user) { create(:user) }
  let!(:team) { create(:team, owners: [user]) }

  describe "#execute" do
    context "with valid params" do
      subject(:service) { Namespaces::BuildService.new(user, name: "name", team: team.name) }

      it "builds a new namespace object" do
        namespace = service.execute

        expect(namespace).not_to be_persisted
      end
    end

    context "with invalid team" do
      subject(:service) { Namespaces::BuildService.new(user, name: "name", team: "asd") }

      it "raises record not found exception" do
        expect { service.execute }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "without params" do
      subject(:service) { Namespaces::BuildService.new(user) }

      it "does not build a namespace object" do
        expect(service.execute).to be_nil
      end
    end
  end
end
