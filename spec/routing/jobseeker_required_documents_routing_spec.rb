require "rails_helper"

RSpec.describe JobseekerRequiredDocumentsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/jobseeker_required_documents").to route_to("jobseeker_required_documents#index")
    end

    it "routes to #new" do
      expect(:get => "/jobseeker_required_documents/new").to route_to("jobseeker_required_documents#new")
    end

    it "routes to #show" do
      expect(:get => "/jobseeker_required_documents/1").to route_to("jobseeker_required_documents#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/jobseeker_required_documents/1/edit").to route_to("jobseeker_required_documents#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/jobseeker_required_documents").to route_to("jobseeker_required_documents#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/jobseeker_required_documents/1").to route_to("jobseeker_required_documents#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/jobseeker_required_documents/1").to route_to("jobseeker_required_documents#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/jobseeker_required_documents/1").to route_to("jobseeker_required_documents#destroy", :id => "1")
    end

  end
end
