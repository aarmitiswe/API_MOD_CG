require "rails_helper"

RSpec.describe JobseekerPackageBroadcastsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/jobseeker_package_broadcasts").to route_to("jobseeker_package_broadcasts#index")
    end

    it "routes to #new" do
      expect(:get => "/jobseeker_package_broadcasts/new").to route_to("jobseeker_package_broadcasts#new")
    end

    it "routes to #show" do
      expect(:get => "/jobseeker_package_broadcasts/1").to route_to("jobseeker_package_broadcasts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/jobseeker_package_broadcasts/1/edit").to route_to("jobseeker_package_broadcasts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/jobseeker_package_broadcasts").to route_to("jobseeker_package_broadcasts#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/jobseeker_package_broadcasts/1").to route_to("jobseeker_package_broadcasts#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/jobseeker_package_broadcasts/1").to route_to("jobseeker_package_broadcasts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/jobseeker_package_broadcasts/1").to route_to("jobseeker_package_broadcasts#destroy", :id => "1")
    end

  end
end
