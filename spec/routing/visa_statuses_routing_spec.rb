require "rails_helper"

RSpec.describe VisaStatusesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/visa_statuses").to route_to("visa_statuses#index")
    end

    it "routes to #new" do
      expect(:get => "/visa_statuses/new").to route_to("visa_statuses#new")
    end

    it "routes to #show" do
      expect(:get => "/visa_statuses/1").to route_to("visa_statuses#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/visa_statuses/1/edit").to route_to("visa_statuses#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/visa_statuses").to route_to("visa_statuses#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/visa_statuses/1").to route_to("visa_statuses#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/visa_statuses/1").to route_to("visa_statuses#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/visa_statuses/1").to route_to("visa_statuses#destroy", :id => "1")
    end

  end
end
