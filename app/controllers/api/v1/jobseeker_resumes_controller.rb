class Api::V1::JobseekerResumesController < ApplicationController
  before_action :set_jobseeker, except: [:application]
  before_action :set_jobseeker_resume, only: [:show, :update, :destroy, :delete_document]
  before_action :set_job_application, only: [:application]
  before_action :jobseeker_owner

  # GET /jobseeker_resumes
  # GET /jobseeker_resumes.json
  def index
    @jobseeker_resumes = @jobseeker.jobseeker_resumes.order(default: :desc)
    render json: @jobseeker_resumes
  end

  # GET /jobseeker_resumes/1
  # GET /jobseeker_resumes/1.json
  def show
    render json: @jobseeker_resume
  end

  # POST /jobseeker_resumes
  # POST /jobseeker_resumes.json
  def create
    @jobseeker_resume = @jobseeker.jobseeker_resumes.new(jobseeker_resume_params)

    if @jobseeker_resume.save
      render json: @jobseeker_resume
    else
      render json: @jobseeker_resume.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /jobseeker_resumes/1
  # PATCH/PUT /jobseeker_resumes/1.json
  def update
    if @jobseeker_resume.update(jobseeker_resume_params)
      render json: @jobseeker_resume
    else
      render json: @jobseeker_resume.errors, status: :unprocessable_entity
    end
  end

  def application
    resumes = @jobseeker.jobseeker_resumes
    resumes.each { |r| r.destroy }
    params = jobseeker_resume_params.merge({ jobseeker_id: @jobseeker.id })
    @jobseeker_resume = JobseekerResume.new(params)

    if @jobseeker_resume.save
      JobApplicationLog.create!(
        log_type: 'updating_candidate_cv',
        user: @current_user,
        job_application: @job_application
      )
      render json: @jobseeker_resume
    else
      render json: @jobseeker_resume.errors, status: :unprocessable_entity
    end
  end

  # DELETE /jobseeker_resumes/1
  # DELETE /jobseeker_resumes/1.json
  def destroy
    @jobseeker_resume.destroy
    render nothing: true, status: 204
  end

  def delete_document
    @jobseeker_resume.delete_document
    render nothing: true, status: 204
  end

  # DELETE /jobseeker_resumes/delete_bulk
  # DELETE /jobseeker_resumes/delete_bulk.json
  def delete_bulk
    soft_delete_ids = JobApplication.where(jobseeker_resume_id: params[:jobseeker_resume_ids]).map(&:jobseeker_resume_id)
    JobseekerResume.where(id: soft_delete_ids).update_all(is_deleted: true)
    JobseekerResume.where(id: params[:jobseeker_resume_ids] - soft_delete_ids, jobseeker_id: @jobseeker.id).destroy_all
    render json: @jobseeker.jobseeker_resumes.try(:order, 'jobseeker_resumes.default DESC')
  end

  private
    def set_jobseeker
      @jobseeker = User.find_by_id(params[:jobseeker_id]).try(:jobseeker)
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_jobseeker_resume
      @jobseeker_resume = JobseekerResume.find_by_id(params[:id])
    end

    def set_job_application
      @job_application = JobApplication.find(params[:job_application_id])
      @jobseeker = @job_application.jobseeker
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def jobseeker_resume_params
      params.require(:jobseeker_resume).permit(:jobseeker_id, :title, :default, :document, :is_deleted => false)
    end

    def jobseeker_owner
      if @current_user.is_jobseeker? && (params[:jobseeker_id].nil? || @current_user.id != params[:jobseeker_id].to_i)
        @current_ability.cannot params[:action].to_sym, JobseekerResume
        authorize!(params[:action].to_sym, JobseekerResume)
      end
    end
end
