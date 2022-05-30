class Api::V1::EvaluationSubmitsController < ApplicationController
  before_action :set_evaluation_submit, only: [:show, :update, :destroy]

  # GET /evaluation_submits
  # GET /evaluation_submits.json
  def index
    # q[job_application_id_eq]=1&q[user_id_eq]=2
    params[:q] ||= {}
    if @current_user.is_hiring_manager? || @current_user.is_recruiter? || @current_user.is_recruitment_manager? ||
      JobApplication.find_by_id(params[:q][:job_application_id_eq]).try(:offer_requisitions).try(:pluck, 'user_id').try(:include?, @current_user.id)
      @q = EvaluationSubmit.ransack(params[:q])
    else
      @q = @current_user.evaluation_submits.ransack(params[:q])
    end

    @evaluation_submits = @q.result
    render json: @evaluation_submits
  end

  # GET /evaluation_submits/1
  # GET /evaluation_submits/1.json
  def show
    render json: @evaluation_submit
  end

  def show_pdf
    if @current_user.is_hiring_manager? || @current_user.is_recruiter?
      @q = EvaluationSubmit.ransack(params[:q])
    else
      @q = @current_user.evaluation_submits.ransack(params[:q])
    end

    @evaluation_submits = @q.result
    render pdf: 'evaluation_form', handlers: [:erb], formats: [:html]
  end

  # POST /evaluation_submits
  # POST /evaluation_submits.json
  def create
    @evaluation_submit = EvaluationSubmit.new(evaluation_submit_params)

    if @evaluation_submit.save
      render json: @evaluation_submit
    else
      render json: @evaluation_submit.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /evaluation_submits/1
  # PATCH/PUT /evaluation_submits/1.json
  def update
    if @evaluation_submit.update(evaluation_submit_params)
      render json: @evaluation_submit
    else
      render json: @evaluation_submit.errors, status: :unprocessable_entity
    end
  end

  # DELETE /evaluation_submits/1
  # DELETE /evaluation_submits/1.json
  def destroy
    @evaluation_submit.destroy
    render nothing: true, status: :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_evaluation_submit
      @evaluation_submit = EvaluationSubmit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def evaluation_submit_params
      params.require(:evaluation_submit).permit(:job_application_id, :evaluation_form_id, :comment, :user_id,
                                                :total_score,
                                                evaluation_answers_attributes: [:evaluation_question_id, :answer])
    end
end
