# frozen_string_literal: true

require "rails_helper"

# It creates a registry (by force so reachability is not checked) by using the
# create service. It accepts a boolean parameter: set it to true if you want the
# `persisted?` to be mocked (returning false).
def create_registry_with_service(should_mock)
  allow_any_instance_of(Registry).to receive(:persisted?).and_return(false) if should_mock
  svc = ::Registries::CreateService.new(nil, name: "test", hostname: "test.lan", use_ssl: false)
  svc.force = true
  svc.execute
  svc
end

describe "Registries::CreateService" do
  describe "#execute" do
    it "marks the registry as invalid if it didn't persist" do
      svc = create_registry_with_service(true)
      expect(svc).not_to be_valid
    end

    it "is valid if it did persist" do
      svc = create_registry_with_service(false)
      expect(svc).to be_valid
    end
  end
end
