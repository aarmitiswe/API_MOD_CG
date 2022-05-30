require "rails_helper"

RSpec.describe JobseekerFoldersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/jobseeker_folders").to route_to("jobseeker_folders#index")
    end

    it "routes to #new" do
      expect(:get => "/jobseeker_folders/new").to route_to("jobseeker_folders#new")
    end

    it "routes to #show" do
      expect(:get => "/jobseeker_folders/1").to route_to("jobseeker_folders#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/jobseeker_folders/1/edit").to route_to("jobseeker_folders#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/jobseeker_folders").to route_to("jobseeker_folders#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/jobseeker_folders/1").to route_to("jobseeker_folders#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/jobseeker_folders/1").to route_to("jobseeker_folders#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/jobseeker_folders/1").to route_to("jobseeker_folders#destroy", :id => "1")
    end

  end
end
