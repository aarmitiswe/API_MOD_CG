class Api::V1::PositionCvSourcesController < ApplicationController
    skip_before_action :authenticate_user
  
    # GET /job_statuses
    # GET /job_statuses.json
    def index
      @position_cv_source = PositionCvSource.all
      render json: @position_cv_source, each_serializer: PositionCvSourceSerializer, ar: params[:ar]
    end
end