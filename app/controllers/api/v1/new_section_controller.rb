class Api::V1::NewSectionController < ApplicationController
  before_action :set_unit, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::InvalidForeignKey, with: :invalid_foreign_key

  # GET /units
  # GET /units.json
  def index
    params[:q] ||= {}
    per_page = params[:all] ? NewSection.count : NewSection.per_page

    if params[:q][:section_id_eq] || params[:q][:office_id_eq] ||
       params[:q][:department_id_eq] || params[:q][:unit_id_eq] || params[:q][:grade_id_eq]
       @q = NewSection.where(id: HiringManager.ransack(params[:q]).result(distinct: true).pluck(:new_section_id)).order(created_at: :desc).ransack(params[:q])
    else
    	@q = NewSection.order(created_at: :desc).ransack(params[:q])
    end

    @section = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @section, meta: pagination_meta(@section)
  end

  # GET /units/1
  # GET /units/1.json
  def show
    render json: @section
  end

  # POST /units
  # POST /units.json
  def create
    @section = NewSection.create(section_params)

    if @section
      render json: @section
    else
      render json: @section.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    if @section.update(section_params)
      render json: @section
    else
      render json: @section.errors, status: :unprocessable_entity
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
     if @section.destroy
      render nothing: true, status: :no_content
    else
      render json: @section.error
    end
  end


  def invalid_foreign_key
    render json: {error: 'foreign_key'}, status: 403
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unit
      @section = NewSection.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def section_params
      params.require(:section).permit(:name, :ar_name, :department_id,:unit_id)
    end
end
