class Api::V1::RequisitionsController < ApplicationController
  before_action :set_requisition, only: [:show, :update, :destroy]

  # GET /requisitions
  # GET /requisitions.json
  def index

    # @requisitions = Requisition.all
    #
    # pending_requisitions = []
    #
    # @requisitions.each do |req|
    #   pending_requisitions << req.job.requisitions.sent.first
    # end
    #
    # render json: pending_requisitions.flatten.uniq
    per_page = params[:all] ? Requisition.count : Requisition.per_page
    @q = @current_user.requisitions_active.ransack(params[:q])
    @requisitions = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @requisitions, meta: pagination_meta(@requisitions)
  end

  def received
    per_page = params[:all] ? Requisition.count : Requisition.per_page
    @q = @current_user.requisitions_active.ransack(params[:q])
    @requisitions = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @requisitions, meta: pagination_meta(@requisitions)
  end

  def sent
    per_page = params[:all] ? Requisition.count : Requisition.per_page
    @q = Requisition.where(id: @current_user.jobs.map{|job| job.requisition_ids}.flatten).ransack(params[:q])
    @requisitions = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @requisitions, meta: pagination_meta(@requisitions)
  end

  # GET /requisitions/1
  # GET /requisitions/1.json
  def show
    render json: @requisition
  end

  # POST /requisitions
  # POST /requisitions.json
  def create
    @requisition = Requisition.new(requisition_params)

    if @requisition.save
      render json: @requisition
    else
      render json: @requisition.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /requisitions/1
  # PATCH/PUT /requisitions/1.json
  def update
    if @requisition.update(requisition_params)
      if @requisition.status == Requisition::APPROVE_STATUS && @requisition.approved_at.nil?
        @requisition.update_column(:approved_at, DateTime.now)
      end
      render json: @requisition
    else
      render json: @requisition.errors, status: :unprocessable_entity
    end
  end

  # DELETE /requisitions/1
  # DELETE /requisitions/1.json
  def destroy
    @requisition.destroy
    render nothing: true, status: :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_requisition
      @requisition = Requisition.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def requisition_params
      params.require(:requisition).permit(:status, :user_id, :job_id, :reason)
    end
end
