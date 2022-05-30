class Api::V1::SavedJobsController < ApplicationController
  before_action :set_jobseeker
  before_action :set_job, only: [:destroy]

  # GET /saved_jobs
  # GET /saved_jobs.json
  def index
    @jobs = Job.calculate_matching_percentage(@current_user.jobseeker, {id_in: @current_user.jobseeker.jobs.pluck(:id) << -1}, params[:order]).paginate(page: params[:page])
    render json: @jobs, meta: pagination_meta(@jobs), each_serializer: JobListSerializer, root: :jobs, ar: params[:ar]
  end

  # POST /saved_jobs
  # POST /saved_jobs.json
  def create
    @saved_job = @jobseeker.saved_jobs.new(saved_job_params)

    if @saved_job.save
      render json: @saved_job, serializer: SavedJobSerializer, root: :saved_job, ar: params[:ar]
    else
      render json: @saved_job.errors, status: :unprocessable_entity
    end
  end

  # DELETE /saved_jobs/1
  # DELETE /saved_jobs/1.json
  def destroy
    SavedJob.find_by(job_id: @job.id, jobseeker_id: @jobseeker.id).destroy
    render json: @jobseeker.saved_jobs, each_serializer: SavedJobSerializer, root: :saved_jobs, ar: params[:ar]
  end

  def delete_bulk
    SavedJob.where(job_id: params[:job_ids], jobseeker_id: @jobseeker.id).destroy_all
    render json: @jobseeker.saved_jobs, each_serializer: SavedJobSerializer, root: :saved_jobs, ar: params[:ar]
  end

  private
    def set_jobseeker
      @jobseeker = User.find_by_id(params[:jobseeker_id]).try(:jobseeker)
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:job_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def saved_job_params
      params.require(:saved_job).permit(:jobseeker_id, :job_id)
    end

    def jobseeker_owner
      if params[:jobseeker_id].nil? || @current_user.id != params[:jobseeker_id].to_i
        @current_ability.cannot params[:action].to_sym, Jobseeker
        authorize!(params[:action].to_sym, Jobseeker)
      end
    end
end
