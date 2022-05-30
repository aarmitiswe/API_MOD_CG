class Api::V1::SectionsController < ApplicationController
  before_action :set_section, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::InvalidForeignKey, with: :invalid_foreign_key

  # GET /sections
  # GET /sections.json
  def index
    params[:q] ||= {}
    per_page = params[:all] ? Section.count : Section.per_page

    if params[:q][:section_id_eq] || params[:q][:office_id_eq] ||
        params[:q][:department_id_eq] || params[:q][:unit_id_eq] || params[:q][:grade_id_eq]
      @q = Section.where(id: HiringManager.ransack(params[:q]).result(distinct: true).pluck(:section_id)).order(created_at: :desc).ransack(params[:q])
    else
      @q = Section.order(created_at: :desc).ransack(params[:q])
    end

    @sections = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @sections, meta: pagination_meta(@sections)
  end

  # GET /sections/1
  # GET /sections/1.json
  def show
    render json: @section
  end

  # POST /sections
  # POST /sections.json
  def create
    @section = Section.create(section_params)

    if @section
      render json: @section
    else
      render json: @section.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sections/1
  # PATCH/PUT /sections/1.json
  def update
    if @section.update(section_params)
      render json: @section
    else
      render json: @section.errors, status: :unprocessable_entity
    end
  end

  # DELETE /sections/1
  # DELETE /sections/1.json
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
    def set_section
      @section = Section.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def section_params
      params.require(:section).permit(:name, :ar_name)
    end
end
