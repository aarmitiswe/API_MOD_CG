require "rails_helper"

RSpec.describe SavedJobsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/saved_jobs").to route_to("saved_jobs#index")
    end

    it "routes to #new" do
      expect(:get => "/saved_jobs/new").to route_to("saved_jobs#new")
    end

    it "routes to #show" do
      expect(:get => "/saved_jobs/1").to route_to("saved_jobs#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/saved_jobs/1/edit").to route_to("saved_jobs#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/saved_jobs").to route_to("saved_jobs#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/saved_jobs/1").to route_to("saved_jobs#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/saved_jobs/1").to route_to("saved_jobs#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/saved_jobs/1").to route_to("saved_jobs#destroy", :id => "1")
    end

  end
end
