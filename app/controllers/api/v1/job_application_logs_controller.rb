class Api::V1::JobApplicationLogsController < ApplicationController

  def index
    @q = JobApplicationLog.ransack(params[:q])
    @logs = @q.result
    render json: @logs, each_serializer: JobApplicationLogSerializer, ar: params[:ar]
  end
end