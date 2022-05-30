require "rails_helper"

RSpec.describe JobApplicationStatusChangesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/job_application_status_changes").to route_to("job_application_status_changes#index")
    end

    it "routes to #new" do
      expect(:get => "/job_application_status_changes/new").to route_to("job_application_status_changes#new")
    end

    it "routes to #show" do
      expect(:get => "/job_application_status_changes/1").to route_to("job_application_status_changes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/job_application_status_changes/1/edit").to route_to("job_application_status_changes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/job_application_status_changes").to route_to("job_application_status_changes#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/job_application_status_changes/1").to route_to("job_application_status_changes#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/job_application_status_changes/1").to route_to("job_application_status_changes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/job_application_status_changes/1").to route_to("job_application_status_changes#destroy", :id => "1")
    end

  end
end
