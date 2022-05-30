require "rails_helper"

RSpec.describe OfferApproversController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/offer_approvers").to route_to("offer_approvers#index")
    end

    it "routes to #new" do
      expect(:get => "/offer_approvers/new").to route_to("offer_approvers#new")
    end

    it "routes to #show" do
      expect(:get => "/offer_approvers/1").to route_to("offer_approvers#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/offer_approvers/1/edit").to route_to("offer_approvers#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/offer_approvers").to route_to("offer_approvers#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/offer_approvers/1").to route_to("offer_approvers#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/offer_approvers/1").to route_to("offer_approvers#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/offer_approvers/1").to route_to("offer_approvers#destroy", :id => "1")
    end

  end
end
