require "rails_helper"

RSpec.describe OfferLetterRequestsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/offer_letter_requests").to route_to("offer_letter_requests#index")
    end

    it "routes to #new" do
      expect(:get => "/offer_letter_requests/new").to route_to("offer_letter_requests#new")
    end

    it "routes to #show" do
      expect(:get => "/offer_letter_requests/1").to route_to("offer_letter_requests#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/offer_letter_requests/1/edit").to route_to("offer_letter_requests#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/offer_letter_requests").to route_to("offer_letter_requests#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/offer_letter_requests/1").to route_to("offer_letter_requests#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/offer_letter_requests/1").to route_to("offer_letter_requests#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/offer_letter_requests/1").to route_to("offer_letter_requests#destroy", :id => "1")
    end

  end
end
