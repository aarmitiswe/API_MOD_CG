require "rails_helper"

RSpec.describe InvitedJobseekersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/invited_jobseekers").to route_to("invited_jobseekers#index")
    end

    it "routes to #new" do
      expect(:get => "/invited_jobseekers/new").to route_to("invited_jobseekers#new")
    end

    it "routes to #show" do
      expect(:get => "/invited_jobseekers/1").to route_to("invited_jobseekers#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/invited_jobseekers/1/edit").to route_to("invited_jobseekers#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/invited_jobseekers").to route_to("invited_jobseekers#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/invited_jobseekers/1").to route_to("invited_jobseekers#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/invited_jobseekers/1").to route_to("invited_jobseekers#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/invited_jobseekers/1").to route_to("invited_jobseekers#destroy", :id => "1")
    end

  end
end
