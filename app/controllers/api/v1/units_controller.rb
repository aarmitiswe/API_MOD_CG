class Api::V1::UnitsController < ApplicationController
  before_action :set_unit, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::InvalidForeignKey, with: :invalid_foreign_key

  # GET /units
  # GET /units.json
  def index
    params[:q] ||= {}
    per_page = params[:all] ? Unit.count : Unit.per_page

    if !params[:in_unit] && (params[:q][:section_id_eq] || params[:q][:office_id_eq] ||
       params[:q][:department_id_eq] || params[:q][:unit_id_eq] || params[:q][:grade_id_eq])
       @q = Unit.where(id: HiringManager.ransack(params[:q]).result(distinct: true).pluck(:unit_id)).order(created_at: :desc).ransack(params[:q])
    else
       @q = Unit.order(created_at: :desc).ransack(params[:q])
    end

    @units = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @units, meta: pagination_meta(@units)
  end

  # GET /units/1
  # GET /units/1.json
  def show
    render json: @unit
  end

  # POST /units
  # POST /units.json
  def create
    @unit = Unit.create(unit_params)

    if @unit
      render json: @unit
    else
      render json: @unit.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    if @unit.update(unit_params)
      render json: @unit
    else
      render json: @unit.errors, status: :unprocessable_entity
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
     if @unit.destroy
      render nothing: true, status: :no_content
    else
      render json: @unit.error
    end
  end


  def invalid_foreign_key
    render json: {error: 'foreign_key'}, status: 403
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unit
      @unit = Unit.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def unit_params
      params.require(:unit).permit(:name, :ar_name, :department_id)
    end
end
