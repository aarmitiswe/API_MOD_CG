class Api::V1::JobseekerExperiencesController < ApplicationController
  include HtmlWithArrayHelper

  before_action :set_jobseeker
  before_action :set_jobseeker_experience, only: [:show, :update, :destroy, :delete_document, :upload_document]
  before_action :jobseeker_owner

  # GET /jobseeker_experiences
  # GET /jobseeker_experiences.json
  def index
    @jobseeker_experiences = @jobseeker.jobseeker_experiences
    render json: @jobseeker_experiences
  end

  # GET /jobseeker_experiences/1
  # GET /jobseeker_experiences/1.json
  def show
    render json: @jobseeker_experience
  end

  # POST /jobseeker_experiences
  # POST /jobseeker_experiences.json
  def create
    update_params

    @jobseeker_experience = @jobseeker.jobseeker_experiences.new(jobseeker_experience_params)
    # This code to set default city & country when complete profile
    if (@jobseeker_experience.country.nil? || @jobseeker_experience.city.nil?) &&
        (@jobseeker.user.city.present?)
      @jobseeker_experience.country_id = @jobseeker.user.country_id
      @jobseeker_experience.city_id = @jobseeker.user.city_id
    end
    if @jobseeker_experience.save
      render json: @jobseeker_experience
    else
      render json: @jobseeker_experience.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /jobseeker_experiences/1
  # PATCH/PUT /jobseeker_experiences/1.json
  def update
    update_params

    if @jobseeker_experience.update(jobseeker_experience_params)
      render json: @jobseeker_experience
    else
      render json: @jobseeker_experience.errors, status: :unprocessable_entity
    end
  end

  # DELETE /jobseeker_experiences/1
  # DELETE /jobseeker_experiences/1.json
  def destroy
    @jobseeker_experience.destroy
    render json: @jobseeker.jobseeker_experiences
  end

  # POST /jobseeker_experiences/1/upload_document
  def upload_document
    @jobseeker_experience.upload_document(params[:jobseeker_experience][:document])
    render json: @jobseeker_experience
  end

  # DELETE /jobseeker_experiences/1/delete_document
  def delete_document
    @jobseeker_experience.delete_document
    render json: @jobseeker_experience
  end

  private
    def set_jobseeker
      @jobseeker = User.find_by_id(params[:jobseeker_id]).try(:jobseeker)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_jobseeker_experience
      @jobseeker_experience = JobseekerExperience.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def jobseeker_experience_params
      params.require(:jobseeker_experience).permit(:from, :to, :jobseeker_id, :sector_id, :country_id,
                                                   :city_id, :position, :company_name, :company_id, :department, :description)
    end

    def update_params
      if params[:jobseeker_experience][:description]
        params[:jobseeker_experience][:description] = convert_array_to_html_string(params[:jobseeker_experience][:description])
      end
    end

    def jobseeker_owner
      if params[:jobseeker_id].nil? || @current_user.id != params[:jobseeker_id].to_i
        @current_ability.cannot params[:action].to_sym, JobseekerExperience
        authorize!(params[:action].to_sym, JobseekerExperience)
      end
    end
end
