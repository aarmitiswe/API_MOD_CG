class Api::V1::CareerFairApplicationsController < ApplicationController
  rescue_from ActiveRecord::InvalidForeignKey, with: :invalid_foreign_key
  before_action :set_user
  before_action :jobseeker_owner

  # GET /branches
  # GET /branches.json
  def index
    @career_fair_application = @current_user.jobseeker.career_fair_applications.order(id: :desc).paginate(page: params[:page])
    render json: @career_fair_application, each_serializer: CareerFairApplicationSerializer, root: :career_fair_application, ar: params[:ar], meta: pagination_meta(@career_fair_application)

  end


  # POST /branches
  # POST /branches.json
  def create

    @career_fair_application = @jobseeker.career_fair_applications.new(career_fair_application_params)

    if @career_fair_application.save
      render json: @career_fair_application, serializer: CareerFairApplicationSerializer, root: :career_fair_application, ar: params[:ar]
    else
      render json: @career_fair_application.errors, status: :unprocessable_entity
    end

  end


  private

  def set_user
    @jobseeker = User.find_by_id(params[:jobseeker_id]).try(:jobseeker)
  end

  # job_application_status_id is override on create by callback method
  def career_fair_application_params
      params.require(:career_fair_application).permit(:jobseeker_id, :career_fair_id)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_career_fair_application
    @branch = CareerFairApplication.find(params[:id])
  end

  def invalid_foreign_key
    render json: {error: 'foreign_key'}, status: 403
  end

  def jobseeker_owner
    if @current_user.is_jobseeker? && (params[:jobseeker_id].nil? || @current_user.id != params[:jobseeker_id].to_i)
      @current_ability.cannot params[:action].to_sym, CareerFairApplication
      authorize!(params[:action].to_sym, CareerFairApplication)
    end
  end

end
