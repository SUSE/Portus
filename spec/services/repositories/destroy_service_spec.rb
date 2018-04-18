# frozen_string_literal: true

require "rails_helper"

describe "Repositories::DestroyService" do
  let!(:user)       { create(:admin) }
  let!(:registry)   { create(:registry, hostname: "registry.test.lan") }
  let!(:repository) { create(:repository, namespace: registry.global_namespace, name: "repo") }

  describe "#execute" do
    context "with params" do
      subject(:service) { ::Repositories::DestroyService.new(user) }

      it "destroys repository" do
        expect { service.execute(repository) }.to change(Repository, :count).by(-1)
      end

      it "destroys tags if existent" do
        create(:tag, name: "tag1", repository: repository, digest: "1")
        create(:tag, name: "tag2", repository: repository, digest: "2")

        allow_any_instance_of(Portus::RegistryClient).to(
          receive(:delete)
            .with(repository.full_name, "1", "manifests")
            .and_return(true)
        )
        allow_any_instance_of(Portus::RegistryClient).to(
          receive(:delete)
            .with(repository.full_name, "2", "manifests")
            .and_return(true)
        )

        expect { service.execute(repository) }.to change(Tag, :count).by(-2)
      end

      it "does not destroy repository if tag wasn't destroyed" do
        create(:tag, name: "tag1", repository: repository, digest: "1")

        allow_any_instance_of(Portus::RegistryClient).to receive(:delete) do
          raise ::Portus::RegistryClient::RegistryError, "I AM ERROR."
        end

        expect { service.execute(repository) }.to change(Repository, :count).by(0)
      end

      it "store error in attribute if tag wasn't destroyed" do
        create(:tag, name: "tag1", repository: repository, digest: "1")

        allow_any_instance_of(Portus::RegistryClient).to receive(:delete) do
          raise ::Portus::RegistryClient::RegistryError, "I AM ERROR."
        end

        service.execute(repository)
        expect(service.error).to eq("Could not remove repository: could not remove tag1 tag(s)")
      end

      it "stores error in attribute if repository wasn't destroyed" do
        allow(repository).to receive(:destroy).and_return(false)
        service.execute(repository)
        expect(service.error).to eq("Could not remove repository")
      end
    end

    context "without params" do
      subject(:service) { ::Repositories::DestroyService.new(user) }

      it "raises RecordNotFound exception" do
        expect { service.execute(nil) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
