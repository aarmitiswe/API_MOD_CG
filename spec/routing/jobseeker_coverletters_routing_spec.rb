require "rails_helper"

RSpec.describe JobseekerCoverlettersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/jobseeker_coverletters").to route_to("jobseeker_coverletters#index")
    end

    it "routes to #new" do
      expect(:get => "/jobseeker_coverletters/new").to route_to("jobseeker_coverletters#new")
    end

    it "routes to #show" do
      expect(:get => "/jobseeker_coverletters/1").to route_to("jobseeker_coverletters#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/jobseeker_coverletters/1/edit").to route_to("jobseeker_coverletters#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/jobseeker_coverletters").to route_to("jobseeker_coverletters#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/jobseeker_coverletters/1").to route_to("jobseeker_coverletters#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/jobseeker_coverletters/1").to route_to("jobseeker_coverletters#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/jobseeker_coverletters/1").to route_to("jobseeker_coverletters#destroy", :id => "1")
    end

  end
end
