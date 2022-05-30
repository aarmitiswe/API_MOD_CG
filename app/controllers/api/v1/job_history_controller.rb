class Api::V1::JobHistoryController < ApplicationController

  def index
    @q = JobHistory.ransack(params[:q])
    @history = @q.result
    render json: @history, each_serializer: JobHistory::JobHistorySerializer, ar: params[:ar]
  end
end