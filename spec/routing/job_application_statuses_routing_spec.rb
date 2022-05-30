require "rails_helper"

RSpec.describe JobApplicationStatusesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/job_application_statuses").to route_to("job_application_statuses#index")
    end

    it "routes to #new" do
      expect(:get => "/job_application_statuses/new").to route_to("job_application_statuses#new")
    end

    it "routes to #show" do
      expect(:get => "/job_application_statuses/1").to route_to("job_application_statuses#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/job_application_statuses/1/edit").to route_to("job_application_statuses#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/job_application_statuses").to route_to("job_application_statuses#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/job_application_statuses/1").to route_to("job_application_statuses#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/job_application_statuses/1").to route_to("job_application_statuses#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/job_application_statuses/1").to route_to("job_application_statuses#destroy", :id => "1")
    end

  end
end
