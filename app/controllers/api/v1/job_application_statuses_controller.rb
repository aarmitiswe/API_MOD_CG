class Api::V1::JobApplicationStatusesController < ApplicationController
  skip_before_action :authenticate_user
  # GET /job_application_statuses
  # GET /job_application_statuses.json
  def index
    @job_application_statuses = JobApplicationStatus.order(:order)
    render json: @job_application_statuses, ar: params[:ar]
  end

  def statuses_with_application_count 
    applications = []
    total_applications = 0
    job_application_statuses = []

    statuses = ['Applied', 'Shortlisted', 'Shared', 'Selected', 'Interview', 'PassInterview', 'JobOffer', 'SecurityClearance', 'Assessment', 'OnBoarding', 'Completed', 'Unsuccessful']
    statuses.each { |s| job_application_statuses << JobApplicationStatus.find_by(status: s) }
    job_application_statuses.each do |status|
      if @current_user.is_hiring_manager?
        applications_count = JobApplication.not_deleted.where("shared_with_hiring_manager = ? OR user_id = ?", true, @current_user.id).where(job_id: params[:job_id]).where(job_application_status_id: status.id).count
      else
        applications_count = JobApplication.not_deleted.where(job_id: params[:job_id]).where(job_application_status_id: status.id).count
      end
      result = {
        id: status.id,
        status: status.status,
        ar_status: status.ar_status,
        applications_count: applications_count
      }

      applications << result
      total_applications += applications_count
    end

    # Total job applications
    response = {
      job_application_statuses: applications,
      total_applications: total_applications
    };

    render json: response, ar: params[:ar]
  end

end
