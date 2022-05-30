require "rails_helper"

RSpec.describe SalaryRangesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/salary_ranges").to route_to("salary_ranges#index")
    end

    it "routes to #new" do
      expect(:get => "/salary_ranges/new").to route_to("salary_ranges#new")
    end

    it "routes to #show" do
      expect(:get => "/salary_ranges/1").to route_to("salary_ranges#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/salary_ranges/1/edit").to route_to("salary_ranges#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/salary_ranges").to route_to("salary_ranges#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/salary_ranges/1").to route_to("salary_ranges#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/salary_ranges/1").to route_to("salary_ranges#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/salary_ranges/1").to route_to("salary_ranges#destroy", :id => "1")
    end

  end
end
