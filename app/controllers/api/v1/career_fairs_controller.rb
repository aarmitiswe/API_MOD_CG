class Api::V1::CareerFairsController < ApplicationController
  skip_before_action :authenticate_user
  before_action :set_career_fair, only: [:show, :update, :destroy]

  # GET /branches
  # GET /branches.json
  def index
    if @current_user.present? && @current_user.is_employer?
      @career_fair = CareerFair.active.order(id: :desc).paginate(page: params[:page])
    else
      @career_fair = CareerFair.live.order(id: :desc).paginate(page: params[:page])
    end
    render json: @career_fair, ar: params[:ar], meta: pagination_meta(@career_fair)
  end

  
  # GET /branches/1
  # GET /branches/1.json
  def show
  if @career_fair
    render json: @career_fair, ar: params[:ar]
  else
    render json: {errors: {career_fair: 'Not Found'}}, status: :not_found
  end

  end

  # POST /branches
  # POST /branches.json
  def create
    if @career_fair.save
      render json: @career_fair
    else
      render json: @career_fair.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /branches/1
  # PATCH/PUT /branches/1.json
  def update
    if @career_fair.update(career_fair_params)
      render json: @career_fair
    else
      render json: @career_fair.errors, status: :unprocessable_entity
    end
  end

  # DELETE /branches/1
  # DELETE /branches/1.json
  def destroy
    @career_fair.update_attribute(:deleted, true)
    render nothing: true, status: 204
  end

  def applicants
    career_fair_applications = @career_fair.career_fair_applications.paginate(page: params[:page])
    render json: career_fair_applications, meta: pagination_meta(career_fair_applications),
           each_serializer: CareerFairApplicationSerializer, root: :career_fair_applications, ar: params[:ar]
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_career_fair
    if @current_user.present? && @current_user.is_employer?
      @career_fair = CareerFair.active.find_by_id(params[:id])
    else
      @career_fair = CareerFair.live.find_by_id(params[:id])
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def career_fair_params
    params.require(:career_fair).permit(:title, :country_id, :city_id, :address, :active, :gender, :logo_image, :from,
                                        :to)
  end

end