require "rails_helper"

RSpec.describe SalaryAnalysesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/salary_analyses").to route_to("salary_analyses#index")
    end

    it "routes to #new" do
      expect(:get => "/salary_analyses/new").to route_to("salary_analyses#new")
    end

    it "routes to #show" do
      expect(:get => "/salary_analyses/1").to route_to("salary_analyses#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/salary_analyses/1/edit").to route_to("salary_analyses#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/salary_analyses").to route_to("salary_analyses#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/salary_analyses/1").to route_to("salary_analyses#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/salary_analyses/1").to route_to("salary_analyses#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/salary_analyses/1").to route_to("salary_analyses#destroy", :id => "1")
    end

  end
end
