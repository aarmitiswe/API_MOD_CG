require "rails_helper"

RSpec.describe JobseekerCompanyBroadcastsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/jobseeker_company_broadcasts").to route_to("jobseeker_company_broadcasts#index")
    end

    it "routes to #new" do
      expect(:get => "/jobseeker_company_broadcasts/new").to route_to("jobseeker_company_broadcasts#new")
    end

    it "routes to #show" do
      expect(:get => "/jobseeker_company_broadcasts/1").to route_to("jobseeker_company_broadcasts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/jobseeker_company_broadcasts/1/edit").to route_to("jobseeker_company_broadcasts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/jobseeker_company_broadcasts").to route_to("jobseeker_company_broadcasts#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/jobseeker_company_broadcasts/1").to route_to("jobseeker_company_broadcasts#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/jobseeker_company_broadcasts/1").to route_to("jobseeker_company_broadcasts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/jobseeker_company_broadcasts/1").to route_to("jobseeker_company_broadcasts#destroy", :id => "1")
    end

  end
end
