# frozen_string_literal: true

require "rails_helper"

describe "Namespaces::DestroyService" do
  let!(:registry)   { create(:registry, hostname: "registry.test.lan") }
  let!(:user)       { create(:admin) }
  let!(:team)       { create(:team, owners: [user]) }
  let!(:namespace)  { create(:namespace, team: team, registry: registry) }
  let!(:repository) { create(:repository, namespace: namespace, name: "repo") }
  let!(:tag)        { create(:tag, repository: repository, name: "tag") }

  subject(:service) { ::Namespaces::DestroyService.new(user) }

  context "with params" do
    before do
      allow_any_instance_of(::Repositories::DestroyService).to(receive(:execute).and_return(true))
    end

    it "fails if the given namespace is personal" do
      status = true

      expect { status = service.execute(user.namespace) }
        .to_not(change { Namespace.count + Repository.count })

      expect(status).to be_falsey
      expect(service.error).to eq "Cannot remove personal namespace"
    end

    it "destroys namespace" do
      expect { service.execute(namespace) }.to change(Namespace, :count).by(-1)
    end

    it "stores the error on delete" do
      allow_any_instance_of(Namespace).to(receive(:delete_by!).and_return(false))
      service.execute(namespace)
      expect(service.error).to eq "Could not remove namespace"
    end

    it "stores the errors on repositories that failed to be removed" do
      allow_any_instance_of(::Repositories::DestroyService).to(receive(:execute).and_return(false))
      allow_any_instance_of(::Repositories::DestroyService).to(
        receive(:error).and_return("I AM ERROR")
      )

      expect { service.execute(namespace) }.not_to change(Namespace, :count)
      expect(service.error.size).to eq 1
      expect(service.error[repository.full_name.to_s]).to eq "I AM ERROR"
    end
  end

  context "without params" do
    it "raises RecordNotFound exception" do
      expect { service.execute(nil) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
