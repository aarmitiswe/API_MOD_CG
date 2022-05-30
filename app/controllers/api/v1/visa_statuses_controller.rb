class Api::V1::VisaStatusesController < ApplicationController
  skip_before_action :authenticate_user

  # GET /visa_statuses
  # GET /visa_statuses.json
  def index
    @q = VisaStatus.ransack(params[:q])
    @visa_statuses = @q.result
    render json: @visa_statuses, each_serializer: VisaStatusSerializer, ar: params[:ar]
  end
end
