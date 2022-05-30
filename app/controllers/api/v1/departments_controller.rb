class Api::V1::DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::InvalidForeignKey, with: :invalid_foreign_key

  # This is called if send wrong params to get cities & departments
  rescue_from NoMethodError, with: :render_exception_error

  # GET /api/v1/departments
  # GET /api/v1/departments?order=jobs
  def index
    per_page = params[:all] ? Department.count : Department.per_page
    params[:order] ||= "alphabetical"
    params[:q] ||= {}
    if params[:all] && params[:order] == "jobs"
      @q = Department.order_by_jobs_all.ransack(params[:q])
    end

    if params[:q][:section_id_eq] || params[:q][:office_id_eq] || params[:q][:department_id_eq] || params[:q][:unit_id_eq] || params[:q][:grade_id_eq]
      @q = Department.where(id: HiringManager.ransack(params[:q]).result(distinct: true).pluck(:department_id)).order(created_at: :desc).ransack(params[:q])
    end

    @q ||= Department.send("order_by_#{params[:order]}").ransack(params[:q])



    # if params[:all] && params[:order] == "jobs"
    #   @q = Department.order_by_jobs_all.ransack(params[:q])
    #
    # else if params[:q][:section_id_eq] || params[:q][:office_id_eq] ||
    #     params[:q][:department_id_eq] || params[:q][:unit_id_eq] || params[:q][:grade_id_eq]
    #        @q = Department.where(id: HiringManager.ransack(params[:q]).result(distinct: true).pluck(:grade_id)).order(created_at: :desc).ransack(params[:q])
    #      else
    #        @q = Department.send("order_by_#{params[:order]}").ransack(params[:q])
    #      end






    @departments = @q.result.paginate(page: params[:page], per_page: per_page)
    # @departments = @departments | Department.where.not(id: @departments.map(&:id)) if params[:all]
    render json: @departments, each_serializer: DepartmentSerializer, ar: params[:ar], meta: pagination_meta(@departments)
  end

  # GET /api/v1/departments/1
  def show
    render json: @department
  end

  # POST /departments
  # POST /departments.json
  def create
    @department = Department.create(department_params)

    if @department
      render json: @department
    else
      render json: @department.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /departments/1
  # PATCH/PUT /departments/1.json
  def update
    if @department.update(department_params)
      render json: @department
    else
      render json: @department.errors, status: :unprocessable_entity
    end
  end

  # DELETE /departments/1
  # DELETE /departments/1.json
  def destroy
    if @department.destroy
    render nothing: true, status: :no_content
   else
    render json: @department.error
   end
  end

  def invalid_foreign_key
    render json: {error: 'foreign_key'}, status: 403
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_department
      @department = Department.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def department_params
      params.require(:department).permit(:name, :ar_name)
    end

    def render_exception_error
      render json: {message: "Wrong Params"}, status: :bad_request
    end
end
