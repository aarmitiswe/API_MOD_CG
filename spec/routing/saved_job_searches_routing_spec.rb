require "rails_helper"

RSpec.describe SavedJobSearchesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/saved_job_searches").to route_to("saved_job_searches#index")
    end

    it "routes to #new" do
      expect(:get => "/saved_job_searches/new").to route_to("saved_job_searches#new")
    end

    it "routes to #show" do
      expect(:get => "/saved_job_searches/1").to route_to("saved_job_searches#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/saved_job_searches/1/edit").to route_to("saved_job_searches#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/saved_job_searches").to route_to("saved_job_searches#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/saved_job_searches/1").to route_to("saved_job_searches#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/saved_job_searches/1").to route_to("saved_job_searches#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/saved_job_searches/1").to route_to("saved_job_searches#destroy", :id => "1")
    end

  end
end
