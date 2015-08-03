require "rails_helper"

RSpec.describe RepositoriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/repositories").to route_to("repositories#index")
    end

    it "routes to #show" do
      expect(get: "/repositories/1").to route_to("repositories#show", id: "1")
    end
  end
end
