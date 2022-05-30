class Api::V1::GradesController < ApplicationController
  before_action :set_grade, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::InvalidForeignKey, with: :invalid_foreign_key

  # GET /grades
  # GET /grades.json
  def index
    params[:q] ||= {}
    per_page = params[:all] ? Grade.count : Grade.per_page

    if params[:q][:section_id_eq] || params[:q][:office_id_eq] ||
       params[:q][:department_id_eq] || params[:q][:unit_id_eq] || params[:q][:grade_id_eq]
       @q = Grade.where(id: HiringManager.ransack(params[:q]).result(distinct: true).pluck(:grade_id)).order(created_at: :desc).ransack(params[:q])
    else
       @q = Grade.order(created_at: :desc).ransack(params[:q])
    end

    @grades = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @grades, meta: pagination_meta(@grades)
  end

  # GET /grades/1
  # GET /grades/1.json
  def show
    render json: @grade
  end

  # POST /grades
  # POST /grades.json
  def create
    @grade = Grade.create(grade_params)

    if @grade
      render json: @grade
    else
      render json: @grade.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /grades/1
  # PATCH/PUT /grades/1.json
  def update
    if @grade.update(grade_params)
      render json: @grade
    else
      render json: @grade.errors, status: :unprocessable_entity
    end
  end

  # DELETE /grades/1
  # DELETE /grades/1.json
  def destroy
     if @grade.destroy
      render nothing: true, status: :no_content
    else
      render json: @grade.error
    end
  end


  def invalid_foreign_key
    render json: {error: 'foreign_key'}, status: 403
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grade
      @grade = Grade.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def grade_params
      params.require(:grade).permit(:company_id, :name, :ar_name)
    end
end
