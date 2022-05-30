require "rails_helper"

RSpec.describe OfferRequisitionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/offer_requisitions").to route_to("offer_requisitions#index")
    end

    it "routes to #new" do
      expect(:get => "/offer_requisitions/new").to route_to("offer_requisitions#new")
    end

    it "routes to #show" do
      expect(:get => "/offer_requisitions/1").to route_to("offer_requisitions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/offer_requisitions/1/edit").to route_to("offer_requisitions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/offer_requisitions").to route_to("offer_requisitions#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/offer_requisitions/1").to route_to("offer_requisitions#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/offer_requisitions/1").to route_to("offer_requisitions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/offer_requisitions/1").to route_to("offer_requisitions#destroy", :id => "1")
    end

  end
end
