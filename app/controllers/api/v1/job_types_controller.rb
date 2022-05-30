class Api::V1::JobTypesController < ApplicationController
  skip_before_action :authenticate_user
  # GET /job_types
  # GET /job_types.json
  def index
    @q = JobType.ransack(params[:q])
    @job_types = @q.result
    render json: @job_types, each_serializer: JobTypeSerializer, ar: params[:ar]
  end
end
