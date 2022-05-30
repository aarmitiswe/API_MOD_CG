require "rails_helper"

RSpec.describe BoardingRequisitionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/boarding_requisitions").to route_to("boarding_requisitions#index")
    end

    it "routes to #new" do
      expect(:get => "/boarding_requisitions/new").to route_to("boarding_requisitions#new")
    end

    it "routes to #show" do
      expect(:get => "/boarding_requisitions/1").to route_to("boarding_requisitions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/boarding_requisitions/1/edit").to route_to("boarding_requisitions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/boarding_requisitions").to route_to("boarding_requisitions#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/boarding_requisitions/1").to route_to("boarding_requisitions#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/boarding_requisitions/1").to route_to("boarding_requisitions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/boarding_requisitions/1").to route_to("boarding_requisitions#destroy", :id => "1")
    end

  end
end
