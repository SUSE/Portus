# frozen_string_literal: true

require "rails_helper"

describe "Tags::DestroyService" do
  let!(:user)       { create(:admin) }
  let!(:registry)   { create(:registry, hostname: "registry.test.lan") }
  let!(:repository) { create(:repository, namespace: registry.global_namespace, name: "repo") }
  let!(:tag)        { create(:tag, name: "tag1", repository: repository, digest: "1") }
  let!(:tag2)       { create(:tag, name: "tag2", repository: repository, digest: "2") }

  describe "#execute" do
    context "with params" do
      subject(:service) { ::Tags::DestroyService.new(user) }

      before do
        allow_any_instance_of(Portus::RegistryClient).to(
          receive(:delete)
            .with(repository.full_name, "1", "manifests")
            .and_return(true)
        )
      end

      it "destroys tag" do
        expect { service.execute(tag) }.to change(Tag, :count).by(-1)
      end

      it "destroys repository if last one was removed" do
        allow_any_instance_of(Portus::RegistryClient).to(
          receive(:delete)
            .with(repository.full_name, "2", "manifests")
            .and_return(true)
        )

        service.execute(tag)
        expect { service.execute(tag2) }.to change(Repository, :count).by(-1)
      end

      it "stores error in attribute" do
        allow_any_instance_of(Portus::RegistryClient).to receive(:delete) do
          raise ::Portus::RegistryClient::RegistryError, "I AM ERROR."
        end

        service.execute(tag)
        expect(service.error).to eq("Could not remove <strong>#{tag.name}</strong> tag")
      end
    end

    context "without params" do
      subject(:service) { ::Tags::DestroyService.new(user) }

      it "raises RecordNotFound exception" do
        expect { service.execute(nil) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
