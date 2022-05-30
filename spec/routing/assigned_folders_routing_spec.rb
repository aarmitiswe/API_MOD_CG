require "rails_helper"

RSpec.describe AssignedFoldersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/assigned_folders").to route_to("assigned_folders#index")
    end

    it "routes to #new" do
      expect(:get => "/assigned_folders/new").to route_to("assigned_folders#new")
    end

    it "routes to #show" do
      expect(:get => "/assigned_folders/1").to route_to("assigned_folders#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/assigned_folders/1/edit").to route_to("assigned_folders#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/assigned_folders").to route_to("assigned_folders#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/assigned_folders/1").to route_to("assigned_folders#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/assigned_folders/1").to route_to("assigned_folders#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/assigned_folders/1").to route_to("assigned_folders#destroy", :id => "1")
    end

  end
end
