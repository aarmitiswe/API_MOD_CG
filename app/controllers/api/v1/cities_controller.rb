class Api::V1::CitiesController < ApplicationController
  skip_before_action :authenticate_user

  # GET /cities
  def index
    per_page = params[:all] ? City.count : City.per_page
    params[:q] ||= {}
    params[:order] ||= "alphabetical"

    @q = City.send("order_by_#{params[:order]}").ransack(params[:q])
    @cities = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @cities, each_serializer: CitySerializer, ar: params[:ar], root: :cities, order: params[:order]
  end
end
