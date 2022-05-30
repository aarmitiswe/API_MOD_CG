require "rails_helper"

RSpec.describe OfferLettersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/offer_letters").to route_to("offer_letters#index")
    end

    it "routes to #new" do
      expect(:get => "/offer_letters/new").to route_to("offer_letters#new")
    end

    it "routes to #show" do
      expect(:get => "/offer_letters/1").to route_to("offer_letters#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/offer_letters/1/edit").to route_to("offer_letters#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/offer_letters").to route_to("offer_letters#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/offer_letters/1").to route_to("offer_letters#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/offer_letters/1").to route_to("offer_letters#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/offer_letters/1").to route_to("offer_letters#destroy", :id => "1")
    end

  end
end
