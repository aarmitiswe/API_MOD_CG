class Api::V1::GeoGroupsController < ApplicationController
  skip_before_action :authenticate_user

  def index
    @geo_groups = GeoGroup.all
    render json: @geo_groups
  end
end
