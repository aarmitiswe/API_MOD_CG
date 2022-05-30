class Api::V1::BranchesController < ApplicationController
  # TODO: Remove Un-Used api actions
  before_action :set_branch, only: [:show, :update, :destroy]

  # GET /branches
  # GET /branches.json
  def index
    per_page = params[:all] ? Branch.count : Branch.per_page
    @q = Branch.ransack(params[:q])
    @branches = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @branches, meta: pagination_meta(@branches), each_serializer: BranchSerializer, ar: params[:ar]
  end

  # GET /branches/1
  # GET /branches/1.json
  def show
    render json: @branch, each_serializer: BranchSerializer, ar: params[:ar]
  end

  # POST /branches
  # POST /branches.json
  def create
    @branch = Branch.new(branch_params)

    if @branch.save
      render json: @branch
    else
      render json: @branch.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /branches/1
  # PATCH/PUT /branches/1.json
  def update
    if @branch.update(branch_params)
      render json: @branch
    else
      render json: @branch.errors, status: :unprocessable_entity
    end
  end

  # DELETE /branches/1
  # DELETE /branches/1.json
  def destroy
    @branch.destroy
    respond_to do |format|
      format.html { redirect_to branches_url, notice: 'Branch was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_branch
      @branch = Branch.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def branch_params
      params.require(:branch).permit(:name, :avatar, :ar_name, :ar_avatar, :company_id)
    end
end
