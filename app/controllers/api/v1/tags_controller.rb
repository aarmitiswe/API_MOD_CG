class Api::V1::TagsController < ApplicationController
  skip_before_action :authenticate_user
  # GET /tags
  # GET /tags.json
  def index
    @q = Tag.order(weight: :desc).ransack(params[:q])
    @tags = @q.result.paginate(page: params[:page])
    render json: @tags
  end
end
