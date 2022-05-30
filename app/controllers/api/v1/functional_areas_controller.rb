class Api::V1::FunctionalAreasController < ApplicationController
  skip_before_action :authenticate_user
  before_action :set_functional_area, only: [:show]


  # GET /functional_areas
  def index
    per_page = params[:all] ? Sector.count : Sector.per_page

    @q = FunctionalArea.order(:area).ransack(params[:q])
    @functional_areas = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @functional_areas, each_serializer: FunctionalAreaSerializer, ar: params[:ar]
  end

  # GET /functional_areas/1
  def show
    render json:@functional_area
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_functional_area
    @functional_area = FunctionalArea.find_by_id(params[:id])
  end
end
