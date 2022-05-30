class Api::V1::OfferApproversController < ApplicationController
  before_action :set_offer_approver, only: [:show, :update, :destroy]

  # GET /offer_approvers
  # GET /offer_approvers.json
  def index
    per_page = params[:all] ? OfferApprover.count : OfferApprover.per_page
    @q = OfferApprover.ransack(params[:q])
    @offer_approvers = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @offer_approvers, each_serializer: OfferApproverSerializer, ar: params[:ar], meta: pagination_meta(@offer_approvers)
  end

  # GET /offer_approvers/1
  # GET /offer_approvers/1.json
  def show
  end

  # POST /offer_approvers
  # POST /offer_approvers.json
  def create
    @offer_approver = OfferApprover.new(offer_approver_params)

    if @offer_approver.save
      render json: @offer_approver
    else
      render json: @offer_approver.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /offer_approvers/1
  # PATCH/PUT /offer_approvers/1.json
  def update
    if @offer_approver.update(offer_approver_params)
      render json: @offer_approver
    else
      render json: @offer_approver.errors, status: :unprocessable_entity
    end
  end

  # DELETE /offer_approvers/1
  # DELETE /offer_approvers/1.json
  def destroy
    @offer_approver.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_offer_approver
      @offer_approver = OfferApprover.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def offer_approver_params
      params.require(:offer_approver).permit(:user_id, :level)
    end
end
