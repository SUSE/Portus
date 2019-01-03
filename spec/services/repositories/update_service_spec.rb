# frozen_string_literal: true

require "rails_helper"

describe "Repositories::UpdateService" do
  let!(:user) { create(:user) }
  let!(:admin) { create(:admin) }
  let!(:public_namespace) do
    create(:namespace,
           visibility: Namespace.visibilities[:visibility_public],
           team:       create(:team))
  end
  let!(:repository) { create(:repository, namespace: public_namespace) }

  describe "#execute" do
    context "with params" do
      let(:params) do
        {
          id:         repository.id,
          repository: {
            description: "description"
          }
        }
      end
      subject(:service) { Repositories::UpdateService.new(admin, params) }

      it "updates repository" do
        service.build
        service.execute
        repository.reload
        expect(repository.description).to eq("description")
      end
    end

    context "without params" do
      subject(:service) { Repositories::UpdateService.new(admin) }

      it "returns false" do
        service.build
        expect(service.execute).to be_falsey
      end
    end
  end
end
