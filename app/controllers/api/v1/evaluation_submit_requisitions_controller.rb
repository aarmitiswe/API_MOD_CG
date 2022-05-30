class Api::V1::EvaluationSubmitRequisitionsController < ApplicationController
  before_action :set_evaluation_submit_requisition, only: [:show, :update, :destroy]

  # GET /evaluation_submit_requisitions
  # GET /evaluation_submit_requisitions.json
  def index
    @evaluation_submit_requisitions = EvaluationSubmitRequisition.all
    render json: @evaluation_submit_requisitions
  end

  # GET /evaluation_submit_requisitions/1
  # GET /evaluation_submit_requisitions/1.json
  def show
    render json: @evaluation_submit_requisition
  end

  # POST /evaluation_submit_requisitions
  # POST /evaluation_submit_requisitions.json
  def create
    @evaluation_submit_requisition = EvaluationSubmitRequisition.new(evaluation_submit_requisition_params)

    if @evaluation_submit_requisition.save
      render json: @evaluation_submit_requisition
    else
      render json: @evaluation_submit_requisition.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /evaluation_submit_requisitions/1
  # PATCH/PUT /evaluation_submit_requisitions/1.json
  def update
    if @evaluation_submit_requisition.update(evaluation_submit_requisition_params)
      render json: @evaluation_submit_requisition
    else
      render json: @evaluation_submit_requisition.errors, status: :unprocessable_entity
    end
  end

  # DELETE /evaluation_submit_requisitions/1
  # DELETE /evaluation_submit_requisitions/1.json
  def destroy
    @evaluation_submit_requisition.destroy
    render nothing: true, status: :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_evaluation_submit_requisition
      @evaluation_submit_requisition = EvaluationSubmitRequisition.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def evaluation_submit_requisition_params
      params.require(:evaluation_submit_requisition).permit(:status).merge!(approved_at: DateTime.now, user_id: @current_user.id)
    end
end
