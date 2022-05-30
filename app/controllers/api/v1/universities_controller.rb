class Api::V1::UniversitiesController < ApplicationController
  skip_before_action :authenticate_user

  # GET /api/v1/universities
  def index
    @q = University.order(:name).ransack(params[:q])
    @universities = @q.result.paginate(page: params[:page])

    render json: @universities, each_serializer: UniversitySerializer, ar: params[:ar], meta: pagination_meta(@universities)
  end
end