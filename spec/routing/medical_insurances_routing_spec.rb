require "rails_helper"

RSpec.describe MedicalInsurancesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/medical_insurances").to route_to("medical_insurances#index")
    end

    it "routes to #new" do
      expect(:get => "/medical_insurances/new").to route_to("medical_insurances#new")
    end

    it "routes to #show" do
      expect(:get => "/medical_insurances/1").to route_to("medical_insurances#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/medical_insurances/1/edit").to route_to("medical_insurances#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/medical_insurances").to route_to("medical_insurances#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/medical_insurances/1").to route_to("medical_insurances#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/medical_insurances/1").to route_to("medical_insurances#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/medical_insurances/1").to route_to("medical_insurances#destroy", :id => "1")
    end

  end
end
