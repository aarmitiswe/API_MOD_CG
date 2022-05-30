require "rails_helper"

RSpec.describe JobExperienceLevelsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/job_experience_levels").to route_to("job_experience_levels#index")
    end

    it "routes to #new" do
      expect(:get => "/job_experience_levels/new").to route_to("job_experience_levels#new")
    end

    it "routes to #show" do
      expect(:get => "/job_experience_levels/1").to route_to("job_experience_levels#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/job_experience_levels/1/edit").to route_to("job_experience_levels#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/job_experience_levels").to route_to("job_experience_levels#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/job_experience_levels/1").to route_to("job_experience_levels#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/job_experience_levels/1").to route_to("job_experience_levels#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/job_experience_levels/1").to route_to("job_experience_levels#destroy", :id => "1")
    end

  end
end
