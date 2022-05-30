require "rails_helper"

RSpec.describe EvaluationSubmitRequisitionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/evaluation_submit_requisitions").to route_to("evaluation_submit_requisitions#index")
    end

    it "routes to #new" do
      expect(:get => "/evaluation_submit_requisitions/new").to route_to("evaluation_submit_requisitions#new")
    end

    it "routes to #show" do
      expect(:get => "/evaluation_submit_requisitions/1").to route_to("evaluation_submit_requisitions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/evaluation_submit_requisitions/1/edit").to route_to("evaluation_submit_requisitions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/evaluation_submit_requisitions").to route_to("evaluation_submit_requisitions#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/evaluation_submit_requisitions/1").to route_to("evaluation_submit_requisitions#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/evaluation_submit_requisitions/1").to route_to("evaluation_submit_requisitions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/evaluation_submit_requisitions/1").to route_to("evaluation_submit_requisitions#destroy", :id => "1")
    end

  end
end
