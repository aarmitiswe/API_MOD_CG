class Api::V1::PollQuestionsController < ApplicationController
  before_action :set_poll_question, only: [:vote]
  before_action :set_poll_question, :user_owner, only: [:update, :destroy]

  # GET /poll_questions
  # GET /poll_questions.json
  # Send params (latest_two = true)
  def index
    @poll_questions = PollQuestion.for_user(@current_user).order(start_at: :desc)
    if params[:latest_two] && @poll_questions.count > 2
      @poll_questions = @poll_questions[0..1]
    end
    @poll_questions.each{ |q| q.calculate_vote_percentage }
    render json: @poll_questions
  end

  # POST /poll_questions
  # POST /poll_questions.json
  def create
    @poll_question = PollQuestion.new(poll_question_params.merge!(user_id: @current_user.id))

    if @poll_question.save
      render json: @poll_question
    else
      render json: @poll_question.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /poll_questions/1
  # PATCH/PUT /poll_questions/1.json
  def update
    if @poll_question.update(poll_question_params)
      render json: @poll_question
    else
      render json: @poll_question.errors, status: :unprocessable_entity
    end
  end

  # DELETE /poll_questions/1
  # DELETE /poll_questions/1.json
  def destroy
    @poll_question.destroy
    render nothing: true, status: 204
  end

  # POST /poll_questions/1/vote
  # This action don't allow users to change their answers
  def vote
    @poll_question = PollResult.vote(@current_user, @poll_question, params[:poll_result][:poll_answer_ids])

    if @poll_question.errors.blank?
      render json: @poll_question
    else
      render json: @poll_question.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_poll_question
      @poll_question = PollQuestion.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def poll_question_params
      params.require(:poll_question).permit(:question, :poll_type, :multiple_selection, :active,
                                        :start_at, :expire_at,
                                        poll_answers_attributes: [:answer])
    end

    def user_owner
      if @poll_question.user_id != @current_user.id
        @current_ability.cannot params[:action].to_sym, User
        authorize!(params[:action].to_sym, User)
      end
    end
end
