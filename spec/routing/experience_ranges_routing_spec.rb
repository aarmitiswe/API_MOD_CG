require "rails_helper"

RSpec.describe ExperienceRangesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/experience_ranges").to route_to("experience_ranges#index")
    end

    it "routes to #new" do
      expect(:get => "/experience_ranges/new").to route_to("experience_ranges#new")
    end

    it "routes to #show" do
      expect(:get => "/experience_ranges/1").to route_to("experience_ranges#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/experience_ranges/1/edit").to route_to("experience_ranges#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/experience_ranges").to route_to("experience_ranges#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/experience_ranges/1").to route_to("experience_ranges#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/experience_ranges/1").to route_to("experience_ranges#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/experience_ranges/1").to route_to("experience_ranges#destroy", :id => "1")
    end

  end
end
