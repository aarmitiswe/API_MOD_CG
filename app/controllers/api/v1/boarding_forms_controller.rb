class Api::V1::BoardingFormsController < ApplicationController
  before_action :set_boarding_form, only: [:show, :edit, :update, :destroy, :generate_pdf]

  # GET /boarding_forms
  # GET /boarding_forms.json
  def index
    @boarding_forms = BoardingForm.all
  end

  # GET /boarding_forms/1
  # GET /boarding_forms/1.json
  def show
  end

  def generate_pdf
    @job_application = @boarding_form.job_application
    @job = @job_application.job
    @jobseeker = @job_application.jobseeker
    @job_application_status_change = @job_application.job_application_status_changes.last

    render template: 'api/v1/boarding_forms/generate_pdf.html.erb', pdf: 'boarding_forms_pdf', handlers: [:erb], formats: [:html]
  end

  # GET /boarding_forms/new
  def new
    @boarding_form = BoardingForm.new
  end

  # GET /boarding_forms/1/edit
  def edit
  end

  # POST /boarding_forms
  # POST /boarding_forms.json
  def create
    @boarding_form = BoardingForm.new(boarding_form_params)

    if @boarding_form.save
      render json: @boarding_form
    else
      render json: @boarding_form.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /boarding_forms/1
  # PATCH/PUT /boarding_forms/1.json
  def update
    if @boarding_form.update(boarding_form_params)
      render json: @boarding_form
    else
      render json: @boarding_form.errors, status: :unprocessable_entity
    end
  end

  # DELETE /boarding_forms/1
  # DELETE /boarding_forms/1.json
  def destroy
    @boarding_form.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_boarding_form
      @boarding_form = BoardingForm.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def boarding_form_params
      params.require(:boarding_form).permit(:title, :owner_position, :job_application_id, :effective_joining_date,
      :copy_number, :expected_joining_date, :signed_joining_document, :signed_stc_document,
                                            :support_management_checked_at, :evaluation_performance_checked_at,
                                            :mod_session_checked_at, :it_management_checked_at, :business_service_management_checked_at, :security_management_checked_at)
    end
end
