class Api::V1::EvaluationQuestionsController < ApplicationController
  before_action :set_evaluation_question, only: [:show, :update, :destroy]

  # GET /evaluation_questions
  # GET /evaluation_questions.json
  def index
    @evaluation_questions = EvaluationQuestion.all
    render json: @evaluation_questions, ar: params[:ar]
  end

  # GET /evaluation_questions/1
  # GET /evaluation_questions/1.json
  def show
    render json: @evaluation_question, ar: params[:ar]
  end

  # POST /evaluation_questions
  # POST /evaluation_questions.json
  def create
    @evaluation_question = EvaluationQuestion.new(evaluation_question_params)

    if @evaluation_question.save
      render json: @evaluation_question, ar: params[:ar]
    else
      render json: @evaluation_question.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /evaluation_questions/1
  # PATCH/PUT /evaluation_questions/1.json
  def update
    if @evaluation_question.update(evaluation_question_params)
      render json: @evaluation_question, ar: params[:ar]
    else
      render json: @evaluation_question.errors, status: :unprocessable_entity
    end
  end

  # DELETE /evaluation_questions/1
  # DELETE /evaluation_questions/1.json
  def destroy
    @evaluation_question.destroy
    render nothing: true, status: :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_evaluation_question
      @evaluation_question = EvaluationQuestion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def evaluation_question_params
      params.require(:evaluation_question).permit(:name, :ar_name, :description, :ar_description, :evaluation_form_id, :question_type, :answers_list)
    end
end
