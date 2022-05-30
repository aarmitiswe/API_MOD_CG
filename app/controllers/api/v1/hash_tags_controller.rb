class Api::V1::HashTagsController < ApplicationController
  def index
    @q = HashTag.ransack(params[:q])
    @hash_tags = @q.result.paginate(page: params[:page])
    render json: @hash_tags
  end
end
