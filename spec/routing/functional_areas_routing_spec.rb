require "rails_helper"

RSpec.describe FunctionalAreasController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/functional_areas").to route_to("functional_areas#index")
    end

    it "routes to #new" do
      expect(:get => "/functional_areas/new").to route_to("functional_areas#new")
    end

    it "routes to #show" do
      expect(:get => "/functional_areas/1").to route_to("functional_areas#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/functional_areas/1/edit").to route_to("functional_areas#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/functional_areas").to route_to("functional_areas#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/functional_areas/1").to route_to("functional_areas#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/functional_areas/1").to route_to("functional_areas#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/functional_areas/1").to route_to("functional_areas#destroy", :id => "1")
    end

  end
end
