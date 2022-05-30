require "rails_helper"

RSpec.describe AlertTypesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/alert_types").to route_to("alert_types#index")
    end

    it "routes to #new" do
      expect(:get => "/alert_types/new").to route_to("alert_types#new")
    end

    it "routes to #show" do
      expect(:get => "/alert_types/1").to route_to("alert_types#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/alert_types/1/edit").to route_to("alert_types#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/alert_types").to route_to("alert_types#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/alert_types/1").to route_to("alert_types#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/alert_types/1").to route_to("alert_types#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/alert_types/1").to route_to("alert_types#destroy", :id => "1")
    end

  end
end
