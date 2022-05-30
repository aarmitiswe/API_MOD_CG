class Api::V1::JobEducationsController < ApplicationController
  skip_before_action :authenticate_user
  before_action :set_job_education, only: [:show]

  # GET /job_educations
  def index
    @q = JobEducation.order(:displayorder).ransack(params[:q])
    @job_educations = @q.result
    render json: @job_educations, each_serializer: JobEducationSerializer, ar: params[:ar]
  end

  # GET /job_educations/1
  def show
    render json: @job_education
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_job_education
    @job_education = JobEducation.find_by_id(params[:id])
  end
end
