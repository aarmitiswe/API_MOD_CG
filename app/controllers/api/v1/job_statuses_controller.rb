class Api::V1::JobStatusesController < ApplicationController
  skip_before_action :authenticate_user

  # GET /job_statuses
  # GET /job_statuses.json
  def index
    @job_statuses = JobStatus.all
    render json: @job_statuses, each_serializer: JobStatusSerializer, ar: params[:ar]
  end
end
