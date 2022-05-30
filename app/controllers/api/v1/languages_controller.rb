class Api::V1::LanguagesController < ApplicationController
  skip_before_action :authenticate_user
  # GET /languages
  # GET /languages.json
  def index
    per_page = params[:all] ? Language.count : Language.per_page

    @q = Language.ransack(params[:q])
    @languages = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @languages, each_serializer: LanguageSerializer, ar: params[:ar], meta: pagination_meta(@languages)
  end
end
