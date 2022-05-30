require "rails_helper"

RSpec.describe JobseekerResumesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/jobseeker_resumes").to route_to("jobseeker_resumes#index")
    end

    it "routes to #new" do
      expect(:get => "/jobseeker_resumes/new").to route_to("jobseeker_resumes#new")
    end

    it "routes to #show" do
      expect(:get => "/jobseeker_resumes/1").to route_to("jobseeker_resumes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/jobseeker_resumes/1/edit").to route_to("jobseeker_resumes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/jobseeker_resumes").to route_to("jobseeker_resumes#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/jobseeker_resumes/1").to route_to("jobseeker_resumes#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/jobseeker_resumes/1").to route_to("jobseeker_resumes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/jobseeker_resumes/1").to route_to("jobseeker_resumes#destroy", :id => "1")
    end

  end
end
