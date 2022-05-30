require "rails_helper"

RSpec.describe MetaTagsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/meta_tags").to route_to("meta_tags#index")
    end

    it "routes to #new" do
      expect(:get => "/meta_tags/new").to route_to("meta_tags#new")
    end

    it "routes to #show" do
      expect(:get => "/meta_tags/1").to route_to("meta_tags#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/meta_tags/1/edit").to route_to("meta_tags#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/meta_tags").to route_to("meta_tags#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/meta_tags/1").to route_to("meta_tags#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/meta_tags/1").to route_to("meta_tags#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/meta_tags/1").to route_to("meta_tags#destroy", :id => "1")
    end

  end
end
