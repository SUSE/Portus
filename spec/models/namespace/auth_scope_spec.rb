# frozen_string_literal: true

require "rails_helper"

describe Namespace::AuthScope, type: :model do
  let!(:registry) { create(:registry) }

  it "handles the global namespace" do
    nm = Namespace.first
    scope = Namespace::AuthScope.new(registry, "registry:busybox:pull")
    expect(scope.resource.id).to eq nm.id
    expect(scope.scopes).to match_array(["pull"])
  end

  it "handles user namespaces" do
    nm = create(:namespace, name: "mssola", registry: registry)
    scope = Namespace::AuthScope.new(registry, "registry:mssola/busybox:pull")
    expect(scope.resource.id).to eq nm.id
    expect(scope.scopes).to match_array(["pull"])
  end

  it "returns namespace instance (not persisted) when it's not found" do
    scope = Namespace::AuthScope.new(registry, "registry:mssola/busybox:pull")
    expect(scope.resource.id).to be_nil
    expect(scope.resource).not_to be_persisted
  end

  it "handles the special action *" do
    nm = create(:namespace, name: "mssola", registry: registry)
    scope = Namespace::AuthScope.new(registry, "registry:mssola/busybox:*")
    expect(scope.resource.id).to eq nm.id
    expect(scope.scopes).to match_array(["all"])
  end
end
