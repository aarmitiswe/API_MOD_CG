require "rails_helper"

RSpec.describe SharedJobseekersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/shared_jobseekers").to route_to("shared_jobseekers#index")
    end

    it "routes to #new" do
      expect(:get => "/shared_jobseekers/new").to route_to("shared_jobseekers#new")
    end

    it "routes to #show" do
      expect(:get => "/shared_jobseekers/1").to route_to("shared_jobseekers#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/shared_jobseekers/1/edit").to route_to("shared_jobseekers#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/shared_jobseekers").to route_to("shared_jobseekers#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/shared_jobseekers/1").to route_to("shared_jobseekers#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/shared_jobseekers/1").to route_to("shared_jobseekers#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/shared_jobseekers/1").to route_to("shared_jobseekers#destroy", :id => "1")
    end

  end
end
