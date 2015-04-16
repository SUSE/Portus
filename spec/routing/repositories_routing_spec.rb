require "rails_helper"

RSpec.describe RepositoriesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/repositories").to route_to("repositories#index")
    end

    it "routes to #new" do
      expect(:get => "/repositories/new").to route_to("repositories#new")
    end

    it "routes to #show" do
      expect(:get => "/repositories/1").to route_to("repositories#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/repositories/1/edit").to route_to("repositories#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/repositories").to route_to("repositories#create")
    end

    it "routes to #update" do
      expect(:put => "/repositories/1").to route_to("repositories#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/repositories/1").to route_to("repositories#destroy", :id => "1")
    end

  end
end
