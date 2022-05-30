class Api::V1::EvaluationFormsController < ApplicationController
  before_action :set_evaluation_form, only: [:show, :update, :destroy, :show_pdf]

  # GET /evaluation_forms
  # GET /evaluation_forms.json
  def index
    @evaluation_forms = EvaluationForm.all
    render json: @evaluation_forms, ar: params[:ar], job_application_id: params[:job_application_id]
  end

  # GET /evaluation_forms/1
  # GET /evaluation_forms/1.json
  def show
    render json: @evaluation_form, ar: params[:ar], job_application_id: params[:job_application_id]
  end

  def show_pdf
    @job_application = JobApplication.find_by_id(params[:job_application_id])
    @jobseeker = @job_application.jobseeker
    @job = @job_application.job
    @interview_committee_member = @job_application.selected_interview_select_stage.interview_committee_members.find_by(user_id: params[:interviewer_id])
    @evaluation_submit = @job_application.evaluation_submits.find_by(user_id: params[:interviewer_id])
    render pdf: 'evaluation_form', handlers: [:erb], formats: [:html]
  end

  # POST /evaluation_forms
  # POST /evaluation_forms.json
  def create
    @evaluation_form = EvaluationForm.new(evaluation_form_params)

    if @evaluation_form.save
      render json: @evaluation_form, ar: params[:ar]
    else
      render json: @evaluation_form.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /evaluation_forms/1
  # PATCH/PUT /evaluation_forms/1.json
  def update
    if @evaluation_form.update(evaluation_form_params)
      render json: @evaluation_form, ar: params[:ar]
    else
      render json: @evaluation_form.errors, status: :unprocessable_entity
    end
  end

  # DELETE /evaluation_forms/1
  # DELETE /evaluation_forms/1.json
  def destroy
    @evaluation_form.destroy
    render nothing: true, status: :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_evaluation_form
      @evaluation_form = EvaluationForm.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def evaluation_form_params
      params.require(:evaluation_form).permit(:name, :ar_name)
    end
end
