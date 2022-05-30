class Api::V1::SectorsController < ApplicationController
  skip_before_action :authenticate_user
  # GET /sectors
  # GET /sectors.json
  def index
    per_page = params[:all] ? Sector.count : Sector.per_page
    params[:order] ||= "alphabetical"



    if params[:all] && params[:order] == "jobs"
      @q = Sector.order_by_jobs_all.ransack(params[:q])
    end

    @q = Sector.send("order_by_#{params[:order]}").ransack(params[:q])
    @sectors = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @sectors, each_serializer: SectorSerializer, ar: params[:ar], meta: pagination_meta(@sectors)
  end
end
