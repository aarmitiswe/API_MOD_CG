require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe SavedJobsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # JobseekerJob. As you add validations to JobseekerJob, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # JobseekerJobsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all saved_jobs as @saved_jobs" do
      saved_job = SavedJob.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:saved_jobs)).to eq([saved_job])
    end
  end

  describe "GET #show" do
    it "assigns the requested saved_job as @saved_job" do
      saved_job = SavedJob.create! valid_attributes
      get :show, {:id => saved_job.to_param}, valid_session
      expect(assigns(:saved_job)).to eq(saved_job)
    end
  end

  describe "GET #new" do
    it "assigns a new saved_job as @saved_job" do
      get :new, {}, valid_session
      expect(assigns(:saved_job)).to be_a_new(SavedJob)
    end
  end

  describe "GET #edit" do
    it "assigns the requested saved_job as @saved_job" do
      saved_job = SavedJob.create! valid_attributes
      get :edit, {:id => saved_job.to_param}, valid_session
      expect(assigns(:saved_job)).to eq(saved_job)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new JobseekerJob" do
        expect {
          post :create, {:saved_job => valid_attributes}, valid_session
        }.to change(SavedJob, :count).by(1)
      end

      it "assigns a newly created saved_job as @saved_job" do
        post :create, {:saved_job => valid_attributes}, valid_session
        expect(assigns(:saved_job)).to be_a(SavedJob)
        expect(assigns(:saved_job)).to be_persisted
      end

      it "redirects to the created saved_job" do
        post :create, {:saved_job => valid_attributes}, valid_session
        expect(response).to redirect_to(SavedJob.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved saved_job as @saved_job" do
        post :create, {:saved_job => invalid_attributes}, valid_session
        expect(assigns(:saved_job)).to be_a_new(SavedJob)
      end

      it "re-renders the 'new' template" do
        post :create, {:saved_job => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested saved_job" do
        saved_job = SavedJob.create! valid_attributes
        put :update, {:id => saved_job.to_param, :saved_job => new_attributes}, valid_session
        saved_job.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested saved_job as @saved_job" do
        saved_job = SavedJob.create! valid_attributes
        put :update, {:id => saved_job.to_param, :saved_job => valid_attributes}, valid_session
        expect(assigns(:saved_job)).to eq(saved_job)
      end

      it "redirects to the saved_job" do
        saved_job = SavedJob.create! valid_attributes
        put :update, {:id => saved_job.to_param, :saved_job => valid_attributes}, valid_session
        expect(response).to redirect_to(saved_job)
      end
    end

    context "with invalid params" do
      it "assigns the saved_job as @saved_job" do
        saved_job = SavedJob.create! valid_attributes
        put :update, {:id => saved_job.to_param, :saved_job => invalid_attributes}, valid_session
        expect(assigns(:saved_job)).to eq(saved_job)
      end

      it "re-renders the 'edit' template" do
        saved_job = SavedJob.create! valid_attributes
        put :update, {:id => saved_job.to_param, :saved_job => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested saved_job" do
      saved_job = SavedJob.create! valid_attributes
      expect {
        delete :destroy, {:id => saved_job.to_param}, valid_session
      }.to change(SavedJob, :count).by(-1)
    end

    it "redirects to the saved_jobs list" do
      saved_job = SavedJob.create! valid_attributes
      delete :destroy, {:id => saved_job.to_param}, valid_session
      expect(response).to redirect_to(saved_jobs_url)
    end
  end

end
