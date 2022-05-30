require "rails_helper"

RSpec.describe CompanyMembersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/company_members").to route_to("company_members#index")
    end

    it "routes to #new" do
      expect(:get => "/company_members/new").to route_to("company_members#new")
    end

    it "routes to #show" do
      expect(:get => "/company_members/1").to route_to("company_members#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/company_members/1/edit").to route_to("company_members#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/company_members").to route_to("company_members#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/company_members/1").to route_to("company_members#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/company_members/1").to route_to("company_members#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/company_members/1").to route_to("company_members#destroy", :id => "1")
    end

  end
end
