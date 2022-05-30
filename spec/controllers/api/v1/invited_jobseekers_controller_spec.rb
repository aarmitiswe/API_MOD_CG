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

RSpec.describe InvitedJobseekersController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # InvitedJobseeker. As you add validations to InvitedJobseeker, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # InvitedJobseekersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all invited_jobseekers as @invited_jobseekers" do
      invited_jobseeker = InvitedJobseeker.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:invited_jobseekers)).to eq([invited_jobseeker])
    end
  end

  describe "GET #show" do
    it "assigns the requested invited_jobseeker as @invited_jobseeker" do
      invited_jobseeker = InvitedJobseeker.create! valid_attributes
      get :show, {:id => invited_jobseeker.to_param}, valid_session
      expect(assigns(:invited_jobseeker)).to eq(invited_jobseeker)
    end
  end

  describe "GET #new" do
    it "assigns a new invited_jobseeker as @invited_jobseeker" do
      get :new, {}, valid_session
      expect(assigns(:invited_jobseeker)).to be_a_new(InvitedJobseeker)
    end
  end

  describe "GET #edit" do
    it "assigns the requested invited_jobseeker as @invited_jobseeker" do
      invited_jobseeker = InvitedJobseeker.create! valid_attributes
      get :edit, {:id => invited_jobseeker.to_param}, valid_session
      expect(assigns(:invited_jobseeker)).to eq(invited_jobseeker)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new InvitedJobseeker" do
        expect {
          post :create, {:invited_jobseeker => valid_attributes}, valid_session
        }.to change(InvitedJobseeker, :count).by(1)
      end

      it "assigns a newly created invited_jobseeker as @invited_jobseeker" do
        post :create, {:invited_jobseeker => valid_attributes}, valid_session
        expect(assigns(:invited_jobseeker)).to be_a(InvitedJobseeker)
        expect(assigns(:invited_jobseeker)).to be_persisted
      end

      it "redirects to the created invited_jobseeker" do
        post :create, {:invited_jobseeker => valid_attributes}, valid_session
        expect(response).to redirect_to(InvitedJobseeker.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved invited_jobseeker as @invited_jobseeker" do
        post :create, {:invited_jobseeker => invalid_attributes}, valid_session
        expect(assigns(:invited_jobseeker)).to be_a_new(InvitedJobseeker)
      end

      it "re-renders the 'new' template" do
        post :create, {:invited_jobseeker => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested invited_jobseeker" do
        invited_jobseeker = InvitedJobseeker.create! valid_attributes
        put :update, {:id => invited_jobseeker.to_param, :invited_jobseeker => new_attributes}, valid_session
        invited_jobseeker.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested invited_jobseeker as @invited_jobseeker" do
        invited_jobseeker = InvitedJobseeker.create! valid_attributes
        put :update, {:id => invited_jobseeker.to_param, :invited_jobseeker => valid_attributes}, valid_session
        expect(assigns(:invited_jobseeker)).to eq(invited_jobseeker)
      end

      it "redirects to the invited_jobseeker" do
        invited_jobseeker = InvitedJobseeker.create! valid_attributes
        put :update, {:id => invited_jobseeker.to_param, :invited_jobseeker => valid_attributes}, valid_session
        expect(response).to redirect_to(invited_jobseeker)
      end
    end

    context "with invalid params" do
      it "assigns the invited_jobseeker as @invited_jobseeker" do
        invited_jobseeker = InvitedJobseeker.create! valid_attributes
        put :update, {:id => invited_jobseeker.to_param, :invited_jobseeker => invalid_attributes}, valid_session
        expect(assigns(:invited_jobseeker)).to eq(invited_jobseeker)
      end

      it "re-renders the 'edit' template" do
        invited_jobseeker = InvitedJobseeker.create! valid_attributes
        put :update, {:id => invited_jobseeker.to_param, :invited_jobseeker => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested invited_jobseeker" do
      invited_jobseeker = InvitedJobseeker.create! valid_attributes
      expect {
        delete :destroy, {:id => invited_jobseeker.to_param}, valid_session
      }.to change(InvitedJobseeker, :count).by(-1)
    end

    it "redirects to the invited_jobseekers list" do
      invited_jobseeker = InvitedJobseeker.create! valid_attributes
      delete :destroy, {:id => invited_jobseeker.to_param}, valid_session
      expect(response).to redirect_to(invited_jobseekers_url)
    end
  end

end