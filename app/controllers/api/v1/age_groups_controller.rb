class Api::V1::AgeGroupsController < ApplicationController
  skip_before_action :authenticate_user
  # GET /age_groups
  # GET /age_groups.json
  def index
    @q = AgeGroup.ransack(params[:q])
    @age_groups = @q.result
    render json: @age_groups
  end
end
