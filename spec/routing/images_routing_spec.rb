require "rails_helper"

RSpec.describe ImagesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/images").to route_to("images#index")
    end

    it "routes to #new" do
      expect(:get => "/images/new").to route_to("images#new")
    end

    it "routes to #show" do
      expect(:get => "/images/1").to route_to("images#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/images/1/edit").to route_to("images#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/images").to route_to("images#create")
    end

    it "routes to #update" do
      expect(:put => "/images/1").to route_to("images#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/images/1").to route_to("images#destroy", :id => "1")
    end

  end
end
