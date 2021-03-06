require "rails_helper"

RSpec.describe CompanyClassificationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/company_classifications").to route_to("company_classifications#index")
    end

    it "routes to #new" do
      expect(:get => "/company_classifications/new").to route_to("company_classifications#new")
    end

    it "routes to #show" do
      expect(:get => "/company_classifications/1").to route_to("company_classifications#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/company_classifications/1/edit").to route_to("company_classifications#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/company_classifications").to route_to("company_classifications#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/company_classifications/1").to route_to("company_classifications#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/company_classifications/1").to route_to("company_classifications#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/company_classifications/1").to route_to("company_classifications#destroy", :id => "1")
    end

  end
end
