require "rails_helper"

RSpec.describe RequisitionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/requisitions").to route_to("requisitions#index")
    end

    it "routes to #new" do
      expect(:get => "/requisitions/new").to route_to("requisitions#new")
    end

    it "routes to #show" do
      expect(:get => "/requisitions/1").to route_to("requisitions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/requisitions/1/edit").to route_to("requisitions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/requisitions").to route_to("requisitions#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/requisitions/1").to route_to("requisitions#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/requisitions/1").to route_to("requisitions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/requisitions/1").to route_to("requisitions#destroy", :id => "1")
    end

  end
end
