require "rails_helper"

RSpec.describe JobseekerOnBoardDocumentsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/jobseeker_on_board_documents").to route_to("jobseeker_on_board_documents#index")
    end

    it "routes to #new" do
      expect(:get => "/jobseeker_on_board_documents/new").to route_to("jobseeker_on_board_documents#new")
    end

    it "routes to #show" do
      expect(:get => "/jobseeker_on_board_documents/1").to route_to("jobseeker_on_board_documents#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/jobseeker_on_board_documents/1/edit").to route_to("jobseeker_on_board_documents#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/jobseeker_on_board_documents").to route_to("jobseeker_on_board_documents#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/jobseeker_on_board_documents/1").to route_to("jobseeker_on_board_documents#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/jobseeker_on_board_documents/1").to route_to("jobseeker_on_board_documents#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/jobseeker_on_board_documents/1").to route_to("jobseeker_on_board_documents#destroy", :id => "1")
    end

  end
end
