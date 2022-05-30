require "rails_helper"

RSpec.describe BoardingFormsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/boarding_forms").to route_to("boarding_forms#index")
    end

    it "routes to #new" do
      expect(:get => "/boarding_forms/new").to route_to("boarding_forms#new")
    end

    it "routes to #show" do
      expect(:get => "/boarding_forms/1").to route_to("boarding_forms#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/boarding_forms/1/edit").to route_to("boarding_forms#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/boarding_forms").to route_to("boarding_forms#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/boarding_forms/1").to route_to("boarding_forms#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/boarding_forms/1").to route_to("boarding_forms#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/boarding_forms/1").to route_to("boarding_forms#destroy", :id => "1")
    end

  end
end
