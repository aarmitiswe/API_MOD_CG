require "rails_helper"

RSpec.describe FeaturedCompaniesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/featured_companies").to route_to("featured_companies#index")
    end

    it "routes to #new" do
      expect(:get => "/featured_companies/new").to route_to("featured_companies#new")
    end

    it "routes to #show" do
      expect(:get => "/featured_companies/1").to route_to("featured_companies#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/featured_companies/1/edit").to route_to("featured_companies#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/featured_companies").to route_to("featured_companies#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/featured_companies/1").to route_to("featured_companies#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/featured_companies/1").to route_to("featured_companies#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/featured_companies/1").to route_to("featured_companies#destroy", :id => "1")
    end

  end
end
