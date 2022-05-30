require "rails_helper"

RSpec.describe JobEducationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/job_educations").to route_to("job_educations#index")
    end

    it "routes to #new" do
      expect(:get => "/job_educations/new").to route_to("job_educations#new")
    end

    it "routes to #show" do
      expect(:get => "/job_educations/1").to route_to("job_educations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/job_educations/1/edit").to route_to("job_educations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/job_educations").to route_to("job_educations#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/job_educations/1").to route_to("job_educations#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/job_educations/1").to route_to("job_educations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/job_educations/1").to route_to("job_educations#destroy", :id => "1")
    end

  end
end
