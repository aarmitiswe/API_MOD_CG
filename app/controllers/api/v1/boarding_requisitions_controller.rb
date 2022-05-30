class Api::V1::BoardingRequisitionsController < ApplicationController
  before_action :set_boarding_requisition, only: [:show, :edit, :update, :destroy]

  # GET /boarding_requisitions
  # GET /boarding_requisitions.json
  def index
    @boarding_requisitions = BoardingRequisition.all
  end

  # GET /boarding_requisitions/1
  # GET /boarding_requisitions/1.json
  def show
  end

  # GET /boarding_requisitions/new
  def new
    @boarding_requisition = BoardingRequisition.new
  end

  # GET /boarding_requisitions/1/edit
  def edit
  end

  # POST /boarding_requisitions
  # POST /boarding_requisitions.json
  def create
    @boarding_requisition = BoardingRequisition.new(boarding_requisition_params)

    if @boarding_requisition.save
      render json: @boarding_requisition
    else
      render json: @boarding_requisition.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /boarding_requisitions/1
  # PATCH/PUT /boarding_requisitions/1.json
  def update
    if @boarding_requisition.update(boarding_requisition_params)
      render json: @boarding_requisition
    else
      render json: @boarding_requisition.errors, status: :unprocessable_entity
    end
  end

  # DELETE /boarding_requisitions/1
  # DELETE /boarding_requisitions/1.json
  def destroy
    @boarding_requisition.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_boarding_requisition
      @boarding_requisition = BoardingRequisition.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def boarding_requisition_params
      params.require(:boarding_requisition).permit(:job_application_id, :user_id, :status, :boarding_form_id, :comment)
    end
end
