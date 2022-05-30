class Api::V1::InterviewsController < ApplicationController
  before_action :set_interview, only: [:show, :generate_token, :update_interview_committee]
  # before_action :jobseeker_owner

  def index
    @accepted_interviews = @current_user.interviews.order(created_at: :desc).where(status: 'accept').where("appointment >= (?)", Date.yesterday.beginning_of_day)
    render json: @accepted_interviews, each_serializer: InterviewSerializer, ar: params[:ar]
  end

  def show
    render json: @interview, serializer: InterviewSerializer, ar: params[:ar]
  end


  # PATCH/PUT /interviews/1
  # PATCH/PUT /interviews/1.json
  # Update By Jobseeker
  def update
    if @interview.update(interview_params)
      render json: @interview, serializer: InterviewSerializer, ar: params[:ar]
    else
      render json: @interview.errors, status: :unprocessable_entity
    end
  end


  def update_interview_committee
    params[:interview] ||= {}
    if @interview.interview_committee_members.count > 0 && params[:interview][:interview_committee_ids]

      begin
        ActiveRecord::Base.transaction do
          if @interview.interview_committee_members.where.not(user_id: params[:interview][:interview_committee_ids]).destroy_all &&
            @job_application.evaluation_submits.where.not(user_id: params[:interview][:interview_committee_ids]).destroy_all
            params[:interview][:interview_committee_ids].each do |sel_user_id|
              if !@interview.interview_committee_members.create({user_id: sel_user_id})
                raise ActiveRecord::Rollback
              end
            end
            JobApplicationLog.create!(
              log_type: 'update_interviewers_committee',
              user: @current_user,
              job_application: @job_application
            )
            render json: {status: 'success'}
          else
            raise ActiveRecord::Rollback
          end
        end
      rescue ActiveRecord::InvalidForeignKey
        render json: {error: 'Error in save', errors: errors}, status: :unprocessable_entity
      end

    else
      render json: {error: 'no_interview_committee'}, status: :unprocessable_entity
    end
  end

  # POST /interviews/create_bulk
  def create_bulk
    job_application_id = params[:job_application_id]
    user_jobseeker_id = params[:interview][:jobseeker_id]
    employer_id = params[:interview][:employer_id]
    appointments = params[:interview][:appointments]
    time_zone = params[:interview][:time_zone]
    comment = params[:interview][:comment]
    duration = params[:interview][:duration]
    interviewer_id = params[:interview][:interviewer_id]
    interviewer_designation = params[:interview][:interviewer_designation]
    #interview_type = params[:interview][:interview_type]

    @interviews = Interview.create_bulk job_application_id, user_jobseeker_id, employer_id, appointments, time_zone, comment, duration, interviewer_id, interviewer_designation
    render json: @interviews, each_serializer: InterviewSerializer, ar: params[:ar]
  end

  def generate_token
    if @interview.is_appointment_not_now?
      render json: { error: "Interview will open before 10 mins, and expired after 1 hour" }, status: :unprocessable_entity
    elsif @interview.generate_interview_token @current_user
      render json: @interview, serializer: InterviewSerializer, ar: params[:ar]
    else
      render json: { error: "Can't Generate the token" }, status: :unprocessable_entity
    end
  end


  # TODO: Refactor by Yakout
  def job_application
    job_application_id = params[:job_application_id]
    job_application_status_change_ids = JobApplicationStatusChange.where(job_application_id: job_application_id).where(:job_application_status_id => [4, 3]).pluck(:id)
    interviews = Interview.where(jobseeker_reply: nil).where(:job_application_status_change_id => job_application_status_change_ids)

    render json: interviews
  end

  def confirm
    # Interview Committee
    interviewer_ids = params[:interviewer_ids]
    confirmed_interview_id = params[:confirmed_interview_id]
    #ToDo: This code needs to be changed later

    errors = []
    begin
      ActiveRecord::Base.transaction do

        Rails.logger.debug "============interviewer_ids============="
        Rails.logger.debug interviewer_ids
        Rails.logger.debug "========================="

        interviewer_ids.each do |id|
          interviewCommitteeMember = InterviewCommitteeMember.new(
              interview_id: confirmed_interview_id, user_id: id)
          if !interviewCommitteeMember.save
            errors = interviewCommitteeMember.errors
            Rails.logger.debug "===========errors=============="
            Rails.logger.debug interviewCommitteeMember.errors
            Rails.logger.debug "========================="
            raise ActiveRecord::Rollback
          end
        end

        # Update confirmed Interview
        Interview.find(confirmed_interview_id).update(is_selected: true)

        # Delete rejected interviews
        # rejected_interview_ids = params[:rejected_interview_ids]
        # Rails.logger.debug "===========rejected_interview_ids=============="
        # Rails.logger.debug rejected_interview_ids
        # Rails.logger.debug "========================="
        # rejected_interview_ids.each do |id|
        #   interview = Interview.find_by_id(id)
        #   interview.destroy if interview
        # end

        # Move to Interview Stage
        job_application_id = params[:job_application_id]
        employer_id = @current_user.id
        # jobseeker_id = params[:jobseeker_id]
        jobseeker_id = JobApplication.find_by_id(job_application_id).jobseeker.user.id
        job_application_status_change = JobApplicationStatusChange.new(jobseeker_id: jobseeker_id, employer_id: employer_id,
                                                                       job_application_status_id: JobApplicationStatus.find_by_status("Interview").id,
                                                                       job_application_id: job_application_id)

        if job_application_status_change.save
        else
          Rails.logger.debug "===========job_application_status_change.errors=============="
          Rails.logger.debug job_application_status_change.errors
          Rails.logger.debug "========================="
          errors = job_application_status_change.errors
        end

        render json: {status: 'success'}

      end
    rescue ActiveRecord::InvalidForeignKey
      render json: {error: 'Error in save', errors: errors}, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interview
      jobseeker_owner
      @job_application = @current_user.is_jobseeker? ? @current_user.jobseeker.job_applications.find_by_id(params[:job_application_id]) :
          @current_user.company.job_applications.find_by_id(params[:job_application_id])

      @interview = @job_application.interviews.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def interview_params
      params.require(:interview).permit(:jobseeker_contact, :status, :jobseeker_reply, :interviewer_id, :appointment)
    end

    def jobseeker_owner
      if @current_user.is_jobseeker? && (params[:job_application_id].nil? ||
          !@current_user.jobseeker.job_application_ids.include?(params[:job_application_id].to_i))
        @current_ability.cannot params[:action].to_sym, Interview
        authorize!(params[:action].to_sym, Interview)
      end
    end
end
