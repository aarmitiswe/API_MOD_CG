require "rails_helper"

RSpec.describe OrganizationUsersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/organization_users").to route_to("organization_users#index")
    end

    it "routes to #new" do
      expect(:get => "/organization_users/new").to route_to("organization_users#new")
    end

    it "routes to #show" do
      expect(:get => "/organization_users/1").to route_to("organization_users#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/organization_users/1/edit").to route_to("organization_users#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/organization_users").to route_to("organization_users#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/organization_users/1").to route_to("organization_users#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/organization_users/1").to route_to("organization_users#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/organization_users/1").to route_to("organization_users#destroy", :id => "1")
    end

  end
end
