class Api::V1::PositionStatusesController < ApplicationController
    skip_before_action :authenticate_user
  
    # GET /job_statuses
    # GET /job_statuses.json
    def index
      @position_statuses = PositionStatus.all
      render json: @position_statuses, each_serializer: PositionStatusSerializer, ar: params[:ar]
    end
end