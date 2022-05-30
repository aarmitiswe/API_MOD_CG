require "rails_helper"

RSpec.describe Api::V1::JobseekerCertificatesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/jobseeker_certificates").to route_to("jobseeker_certificates#index")
    end

    it "routes to #new" do
      expect(:get => "/jobseeker_certificates/new").to route_to("jobseeker_certificates#new")
    end

    it "routes to #show" do
      expect(:get => "/jobseeker_certificates/1").to route_to("jobseeker_certificates#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/jobseeker_certificates/1/edit").to route_to("jobseeker_certificates#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/jobseeker_certificates").to route_to("jobseeker_certificates#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/jobseeker_certificates/1").to route_to("jobseeker_certificates#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/jobseeker_certificates/1").to route_to("jobseeker_certificates#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/jobseeker_certificates/1").to route_to("jobseeker_certificates#destroy", :id => "1")
    end

  end
end
