require "rails_helper"

RSpec.describe OfferAnalysesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/offer_analyses").to route_to("offer_analyses#index")
    end

    it "routes to #new" do
      expect(:get => "/offer_analyses/new").to route_to("offer_analyses#new")
    end

    it "routes to #show" do
      expect(:get => "/offer_analyses/1").to route_to("offer_analyses#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/offer_analyses/1/edit").to route_to("offer_analyses#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/offer_analyses").to route_to("offer_analyses#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/offer_analyses/1").to route_to("offer_analyses#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/offer_analyses/1").to route_to("offer_analyses#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/offer_analyses/1").to route_to("offer_analyses#destroy", :id => "1")
    end

  end
end
