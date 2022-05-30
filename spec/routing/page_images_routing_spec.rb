require "rails_helper"

RSpec.describe PageImagesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/page_images").to route_to("page_images#index")
    end

    it "routes to #new" do
      expect(:get => "/page_images/new").to route_to("page_images#new")
    end

    it "routes to #show" do
      expect(:get => "/page_images/1").to route_to("page_images#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/page_images/1/edit").to route_to("page_images#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/page_images").to route_to("page_images#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/page_images/1").to route_to("page_images#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/page_images/1").to route_to("page_images#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/page_images/1").to route_to("page_images#destroy", :id => "1")
    end

  end
end
