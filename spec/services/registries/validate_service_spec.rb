# frozen_string_literal: true

require "rails_helper"

describe "Registries::ValidateService" do
  describe "#execute" do
    context "invalid without only param" do
      subject(:service) { Registries::ValidateService.new }

      before do
        allow_any_instance_of(Registry).to receive(:reachable?).and_return("Error")
      end

      it "returns an object with validation messages on all the fields" do
        validation = service.execute

        expect(validation[:messages][:name]).to be_truthy
        expect(validation[:messages][:hostname]).to be_truthy
      end

      it "returns object with valid false if validation fails" do
        validation = service.execute

        expect(validation[:valid]).to be_falsey
      end
    end

    context "valid without only param" do
      subject(:service) do
        Registries::ValidateService.new(name: "name", hostname: "something", use_ssl: false)
      end

      before do
        allow_any_instance_of(Registry).to receive(:reachable?).and_return(nil)
      end

      it "returns an object with empty validation on messages" do
        validation = service.execute

        expect(validation[:messages][:name]).to be_blank
        expect(validation[:messages][:hostname]).to be_blank
      end

      it "returns object with valid false if validation succeeds" do
        validation = service.execute

        expect(validation[:valid]).to be_truthy
      end
    end

    context "invalid with name param" do
      subject(:service) { Registries::ValidateService.new(only: ["name"]) }

      it "returns an object with validation messages only on name" do
        validation = service.execute

        expect(validation[:messages][:name]).to_not be_empty
        expect(validation[:messages][:hostname]).to be_empty
      end

      it "returns object with valid false if validation fails" do
        validation = service.execute

        expect(validation[:valid]).to be_falsey
      end
    end

    context "valid with name param" do
      subject(:service) { Registries::ValidateService.new(name: "name", only: ["name"]) }

      it "returns an object with empty validation on messages" do
        validation = service.execute

        expect(validation[:messages][:name]).to be_empty
        expect(validation[:messages][:hostname]).to be_empty
      end

      it "returns object with valid false if validation succeeds" do
        validation = service.execute

        expect(validation[:valid]).to be_truthy
      end
    end

    context "valid with hostname param" do
      subject(:service) do
        Registries::ValidateService.new(
          name:     "test",
          hostname: "hostname",
          use_ssl:  false,
          only:     ["hostname"]
        )
      end

      before do
        allow_any_instance_of(Registry).to receive(:reachable?).and_return(nil)
      end

      it "returns an object with empty validation on messages" do
        validation = service.execute

        expect(validation[:messages][:name]).to be_empty
        expect(validation[:messages][:hostname]).to be_empty
      end

      it "returns object with valid false if validation succeeds" do
        validation = service.execute

        expect(validation[:valid]).to be_truthy
      end
    end

    context "invalid with hostname param" do
      subject(:service) do
        Registries::ValidateService.new(hostname: "hostname", only: ["hostname"])
      end

      before do
        allow_any_instance_of(Registry).to receive(:reachable?).and_return("Error")
      end

      it "returns an object with empty validation on messages" do
        validation = service.execute

        expect(validation[:messages][:name]).to be_empty
        expect(validation[:messages][:hostname]).to be_truthy
      end

      it "returns object with valid false if validation succeeds" do
        validation = service.execute

        expect(validation[:valid]).to be_falsey
      end
    end
  end
end
