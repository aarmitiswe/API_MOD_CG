class Api::V1::OfferRequisitionsController < ApplicationController
  before_action :set_offer_requisition, only: [:show, :edit, :update, :destroy]

  # GET /offer_requisitions
  # GET /offer_requisitions.json
  def index
    @offer_requisitions = OfferRequisition.order(created_at: :asc)
  end

  # GET /offer_requisitions/1
  # GET /offer_requisitions/1.json
  def show
  end

  # GET /offer_requisitions/new
  def new
    @offer_requisition = OfferRequisition.new
  end

  # GET /offer_requisitions/1/edit
  def edit
  end

  # POST /offer_requisitions
  # POST /offer_requisitions.json
  def create
    @offer_requisition = OfferRequisition.new(offer_requisition_params)

    if @offer_requisition.save
      render json: @offer_requisition
    else
      render json: @offer_requisition.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /offer_requisitions/1
  # PATCH/PUT /offer_requisitions/1.json
  def update
    if @offer_requisition.update(offer_requisition_params)
      render json: @offer_requisition
    else
      render json: @offer_requisition.errors, status: :unprocessable_entity
    end
  end

  # DELETE /offer_requisitions/1
  # DELETE /offer_requisitions/1.json
  def destroy
    @offer_requisition.destroy
    respond_to do |format|
      format.html { redirect_to offer_requisitions_url, notice: 'Offer requisition was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_offer_requisition
      @offer_requisition = OfferRequisition.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def offer_requisition_params
      params.require(:offer_requisition).permit(:job_application_id, :status, :comment).merge!(user_id: @current_user.id)
    end
end
