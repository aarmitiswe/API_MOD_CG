require "rails_helper"

RSpec.describe JobRequestsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/job_requests").to route_to("job_requests#index")
    end

    it "routes to #new" do
      expect(:get => "/job_requests/new").to route_to("job_requests#new")
    end

    it "routes to #show" do
      expect(:get => "/job_requests/1").to route_to("job_requests#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/job_requests/1/edit").to route_to("job_requests#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/job_requests").to route_to("job_requests#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/job_requests/1").to route_to("job_requests#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/job_requests/1").to route_to("job_requests#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/job_requests/1").to route_to("job_requests#destroy", :id => "1")
    end

  end
end
