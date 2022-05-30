class Api::V1::JobseekerEducationsController < ApplicationController
  before_action :set_jobseeker
  before_action :set_jobseeker_education, only: [:update, :destroy, :delete_document, :upload_document]
  before_action :jobseeker_owner

  # GET /jobseeker_educations
  # GET /jobseeker_educations.json
  def index
    @jobseeker_educations = @jobseeker.jobseeker_educations
    render json: @jobseeker_educations
  end

  # POST /jobseeker_educations
  # POST /jobseeker_educations.json
  def create
    @jobseeker_education = @jobseeker.jobseeker_educations.new(jobseeker_education_params)
    if @jobseeker_education.save
      render json: @jobseeker_education
    else
      render json: @jobseeker_education.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /jobseeker_educations/1
  # PATCH/PUT /jobseeker_educations/1.json
  def update
    if @jobseeker_education.update(jobseeker_education_params)
      render json: @jobseeker_education
    else
      render json: @jobseeker_education.errors, status: :unprocessable_entity
    end
  end

  # DELETE /jobseeker_educations/1
  # DELETE /jobseeker_educations/1.json
  def destroy
    @jobseeker_education.destroy
    render json: @jobseeker.jobseeker_educations
  end

  # POST /jobseeker_educations/1/upload_document
  def upload_document
    @jobseeker_education.upload_document(params[:jobseeker_education][:document])
    render json: @jobseeker_education
  end

  # DELETE /jobseeker_educations/1/delete_document
  def delete_document
    @jobseeker_education.delete_document
    render json: @jobseeker_education
  end

  private
    def set_jobseeker
      @jobseeker = User.find_by_id(params[:jobseeker_id]).try(:jobseeker)
    end

    def set_jobseeker_education
      JobseekerEducation.find_by_id(params[:id])
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def jobseeker_education_params
      params.require(:jobseeker_education).permit(:job_education_id, :country_id, :city_id, :grade, :degree_type, :school, :field_of_study, :from, :to, :jobseeker_id, :max_grade)
    end

    def jobseeker_owner
      if params[:jobseeker_id].nil? || @current_user.id != params[:jobseeker_id].to_i
        @current_ability.cannot params[:action].to_sym, JobseekerEducation
        authorize!(params[:action].to_sym, JobseekerEducation)
      end
    end
end
