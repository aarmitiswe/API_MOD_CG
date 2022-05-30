require "rails_helper"

RSpec.describe PackageBroadcastsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/package_broadcasts").to route_to("package_broadcasts#index")
    end

    it "routes to #new" do
      expect(:get => "/package_broadcasts/new").to route_to("package_broadcasts#new")
    end

    it "routes to #show" do
      expect(:get => "/package_broadcasts/1").to route_to("package_broadcasts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/package_broadcasts/1/edit").to route_to("package_broadcasts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/package_broadcasts").to route_to("package_broadcasts#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/package_broadcasts/1").to route_to("package_broadcasts#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/package_broadcasts/1").to route_to("package_broadcasts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/package_broadcasts/1").to route_to("package_broadcasts#destroy", :id => "1")
    end

  end
end
