require "rails_helper"

RSpec.describe CompanyTypesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/company_types").to route_to("company_types#index")
    end

    it "routes to #new" do
      expect(:get => "/company_types/new").to route_to("company_types#new")
    end

    it "routes to #show" do
      expect(:get => "/company_types/1").to route_to("company_types#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/company_types/1/edit").to route_to("company_types#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/company_types").to route_to("company_types#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/company_types/1").to route_to("company_types#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/company_types/1").to route_to("company_types#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/company_types/1").to route_to("company_types#destroy", :id => "1")
    end

  end
end
