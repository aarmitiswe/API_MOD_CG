class Api::V1::OfficesController < ApplicationController
  before_action :set_office, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::InvalidForeignKey, with: :invalid_foreign_key

  # GET /offices
  # GET /offices.json
  def index
    params[:q] ||= {}
    per_page = params[:all] ? Office.count : Office.per_page

    if params[:q][:section_id_eq] || params[:q][:office_id_eq] ||
        params[:q][:department_id_eq] || params[:q][:unit_id_eq] || params[:q][:grade_id_eq]
      @q = Office.where(id: HiringManager.ransack(params[:q]).result(distinct: true).pluck(:office_id)).order(created_at: :desc).ransack(params[:q])
    else
      @q = Office.order(created_at: :desc).ransack(params[:q])
    end

    @offices = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @offices, meta: pagination_meta(@offices)
  end

  # GET /offices/1
  # GET /offices/1.json
  def show
    render json: @office
  end

  # POST /offices
  # POST /offices.json
  def create
    @office = Office.create(office_params)

    if @office
      render json: @office
    else
      render json: @office.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /offices/1
  # PATCH/PUT /offices/1.json
  def update

    if @office.update(office_params)
      render json: @office
    else
      render json: @office.errors, status: :unprocessable_entity
    end
  end

  # DELETE /offices/1
  # DELETE /offices/1.json
  def destroy
   if @office.destroy
    render nothing: true, status: :no_content
   else
    render json: @office.error
   end
  end


  def invalid_foreign_key
    render json: {error: 'foreign_key'}, status: 403
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_office
      @office = Office.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def office_params
      params.require(:office).permit(:company_id, :name, :ar_name, :country_id, :city_id)
    end
end
