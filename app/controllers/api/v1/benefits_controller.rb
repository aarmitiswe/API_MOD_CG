class Api::V1::BenefitsController < ApplicationController
  skip_before_action :authenticate_user

  # GET /benefits
  # GET /benefits.json
  def index
    @benefits = Benefit.all
    render json: @benefits, each_serializer: BenefitSerializer, ar: params[:ar]
  end
end
