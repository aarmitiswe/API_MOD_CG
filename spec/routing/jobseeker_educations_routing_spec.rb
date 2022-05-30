require "rails_helper"

RSpec.describe Api::V1::JobseekerEducationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/jobseeker_educations").to route_to("jobseeker_educations#index")
    end

    it "routes to #new" do
      expect(:get => "/jobseeker_educations/new").to route_to("jobseeker_educations#new")
    end

    it "routes to #show" do
      expect(:get => "/jobseeker_educations/1").to route_to("jobseeker_educations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/jobseeker_educations/1/edit").to route_to("jobseeker_educations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/jobseeker_educations").to route_to("jobseeker_educations#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/jobseeker_educations/1").to route_to("jobseeker_educations#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/jobseeker_educations/1").to route_to("jobseeker_educations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/jobseeker_educations/1").to route_to("jobseeker_educations#destroy", :id => "1")
    end

  end
end
