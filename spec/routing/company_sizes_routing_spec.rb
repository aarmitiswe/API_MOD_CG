require "rails_helper"

RSpec.describe CompanySizesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/company_sizes").to route_to("company_sizes#index")
    end

    it "routes to #new" do
      expect(:get => "/company_sizes/new").to route_to("company_sizes#new")
    end

    it "routes to #show" do
      expect(:get => "/company_sizes/1").to route_to("company_sizes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/company_sizes/1/edit").to route_to("company_sizes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/company_sizes").to route_to("company_sizes#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/company_sizes/1").to route_to("company_sizes#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/company_sizes/1").to route_to("company_sizes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/company_sizes/1").to route_to("company_sizes#destroy", :id => "1")
    end

  end
end
