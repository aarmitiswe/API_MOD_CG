class Api::V1::EvaluationAnswersController < ApplicationController
  before_action :set_evaluation_answer, only: [:show, :update, :destroy]

  # GET /evaluation_answers
  # GET /evaluation_answers.json
  def index
    @evaluation_answers = EvaluationAnswer.all
    render json: @evaluation_answers
  end

  # GET /evaluation_answers/1
  # GET /evaluation_answers/1.json
  def show
    render json: @evaluation_answer
  end

  # POST /evaluation_answers
  # POST /evaluation_answers.json
  def create
    @evaluation_answer = EvaluationAnswer.new(evaluation_answer_params)

    if @evaluation_answer.save
      render json: @evaluation_answer
    else
      render json: @evaluation_answer.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /evaluation_answers/1
  # PATCH/PUT /evaluation_answers/1.json
  def update
    if @evaluation_answer.update(evaluation_answer_params)
      render json: @evaluation_answer
    else
      render json: @evaluation_answer.errors, status: :unprocessable_entity
    end
  end

  # DELETE /evaluation_answers/1
  # DELETE /evaluation_answers/1.json
  def destroy
    @evaluation_answer.destroy
    render nothing: true, status: :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_evaluation_answer
      @evaluation_answer = EvaluationAnswer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def evaluation_answer_params
      params.require(:evaluation_answer).permit(:evaluation_submit_id, :evaluation_question_id, :answer)
    end
end
