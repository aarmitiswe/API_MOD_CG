class Api::V1::AlertTypesController < ApplicationController
  skip_before_action :authenticate_user

  # GET /alert_types
  # GET /alert_types.json
  def index
    @alert_types = AlertType.all
    render json: @alert_types, each_serializer: AlertTypeSerializer, ar: params[:ar]
  end
end
