class Api::V1::JobExperienceLevelsController < ApplicationController
  skip_before_action :authenticate_user
  before_action :set_job_education, only: [:show]

  # GET /job_experience_levels
  def index
    @q = JobExperienceLevel.order(:display_order).ransack(params[:q])
    @job_experience_levels = @q.result
    render json: @job_experience_levels, each_serializer: JobExperienceLevelSerializer, ar: params[:ar]
  end

  # GET /job_experience_levels/1
  def show
    render json: @job_experience_level
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_job_education
    @job_experience_level = JobExperienceLevel.find_by_id(params[:id])
  end
end
