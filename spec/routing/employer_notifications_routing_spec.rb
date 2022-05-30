require "rails_helper"

RSpec.describe EmployerNotificationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/employer_notifications").to route_to("employer_notifications#index")
    end

    it "routes to #new" do
      expect(:get => "/employer_notifications/new").to route_to("employer_notifications#new")
    end

    it "routes to #show" do
      expect(:get => "/employer_notifications/1").to route_to("employer_notifications#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/employer_notifications/1/edit").to route_to("employer_notifications#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/employer_notifications").to route_to("employer_notifications#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/employer_notifications/1").to route_to("employer_notifications#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/employer_notifications/1").to route_to("employer_notifications#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/employer_notifications/1").to route_to("employer_notifications#destroy", :id => "1")
    end

  end
end
