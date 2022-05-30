require "rails_helper"

RSpec.describe Api::V1::JobseekerExperiencesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/jobseeker_experiences").to route_to("jobseeker_experiences#index")
    end

    it "routes to #new" do
      expect(:get => "/jobseeker_experiences/new").to route_to("jobseeker_experiences#new")
    end

    it "routes to #show" do
      expect(:get => "/jobseeker_experiences/1").to route_to("jobseeker_experiences#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/jobseeker_experiences/1/edit").to route_to("jobseeker_experiences#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/jobseeker_experiences").to route_to("jobseeker_experiences#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/jobseeker_experiences/1").to route_to("jobseeker_experiences#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/jobseeker_experiences/1").to route_to("jobseeker_experiences#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/jobseeker_experiences/1").to route_to("jobseeker_experiences#destroy", :id => "1")
    end

  end
end
