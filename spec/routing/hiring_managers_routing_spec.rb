require "rails_helper"

RSpec.describe HiringManagersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/hiring_managers").to route_to("hiring_managers#index")
    end

    it "routes to #new" do
      expect(:get => "/hiring_managers/new").to route_to("hiring_managers#new")
    end

    it "routes to #show" do
      expect(:get => "/hiring_managers/1").to route_to("hiring_managers#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/hiring_managers/1/edit").to route_to("hiring_managers#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/hiring_managers").to route_to("hiring_managers#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/hiring_managers/1").to route_to("hiring_managers#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/hiring_managers/1").to route_to("hiring_managers#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/hiring_managers/1").to route_to("hiring_managers#destroy", :id => "1")
    end

  end
end
