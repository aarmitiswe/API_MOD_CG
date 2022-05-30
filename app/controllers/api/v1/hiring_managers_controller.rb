class Api::V1::HiringManagersController < ApplicationController
  before_action :set_hiring_manager, only: [:show, :update, :destroy]

  # GET /hiring_managers
  # GET /hiring_managers.json
  def index
    per_page = params[:all].blank? ? (params[:per_page] || HiringManager.per_page) : HiringManager.active.count
    @hiring_managers = HiringManager.active.order_by_desc.ransack(params[:q]).result.paginate(page: params[:page])
    render json: @hiring_managers, meta: pagination_meta(@hiring_managers)
  end

  # GET /hiring_managers/1
  # GET /hiring_managers/1.json
  def show
    render json: @hiring_manager
  end

  # POST /hiring_managers
  # POST /hiring_managers.json
  def create
    @hiring_manager = HiringManager.new(hiring_manager_params)

    if @hiring_manager.save
      render json: @hiring_manager
    else
      render json: @hiring_manager.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /hiring_managers/1
  # PATCH/PUT /hiring_managers/1.json
  def update
    if @hiring_manager.update(hiring_manager_params)
      render json: @hiring_manager
    else
      render json: @hiring_manager.errors, status: :unprocessable_entity
    end
  end

  # DELETE /hiring_managers/1
  # DELETE /hiring_managers/1.json
  def destroy
    @hiring_manager.update(deleted: true)
    render nothing: true, status: :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hiring_manager
      @hiring_manager = HiringManager.active.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def hiring_manager_params

      params.require(:hiring_manager).permit(:section_id, :office_id, :department_id, :unit_id, :grade_id,
                                             :new_section_id, :approver_one_id, :approver_two_id, :approver_three_id, :approver_four_id,
                                             :approver_five_id, :num_approvers,:hiring_manager_type, hiring_manager_owners_attributes: [:id, :user_id, :_destroy])
    end
end
