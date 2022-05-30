require "rails_helper"

RSpec.describe PollQuestionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/poll_questions").to route_to("poll_questions#index")
    end

    it "routes to #new" do
      expect(:get => "/poll_questions/new").to route_to("poll_questions#new")
    end

    it "routes to #show" do
      expect(:get => "/poll_questions/1").to route_to("poll_questions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/poll_questions/1/edit").to route_to("poll_questions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/poll_questions").to route_to("poll_questions#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/poll_questions/1").to route_to("poll_questions#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/poll_questions/1").to route_to("poll_questions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/poll_questions/1").to route_to("poll_questions#destroy", :id => "1")
    end

  end
end
