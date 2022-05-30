class Api::V1::JobRequestsController < ApplicationController
  before_action :set_job_request, only: [:show, :edit, :update, :destroy]
  before_action :set_approval_date, only: [:update_approvers]

  # GET /job_requests
  # GET /job_requests.json
  def index
    approver_scope_hash = %w(in_progress_approver_one in_progress_approver_two in_progress_approver_three in_progress_approver_four in_progress_approver_five)
    params[:q] ||= {}
    per_page = params[:all].blank? ? (params[:per_page] || JobRequest.per_page) : JobRequest.active.count

    job_request = get_job_request

    # Jobs Request in appoval =  All job Request Not in (Appoved Job Request)
      if params[:in_progress]
        @q =job_request.not_rejected.send(approver_scope_hash[Rails.application.secrets[:NUM_REQUISITION_APPROVERS].to_i - 1]).order(created_at: :desc)
                .ransack(params[:q]
                             .except(:status_approval_one_eq)
                             .except(:status_approval_two_eq)
                             .except(:status_approval_three_eq)
                             .except(:status_approval_four_eq)
                             .except(:status_approval_five_eq))
      elsif  params[:is_rejected]
        @q =job_request.is_rejected.order(created_at: :desc).ransack(params[:q])
      else
        @q =job_request.order(created_at: :desc).ransack(params[:q])
      end

    @job_requests = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @job_requests, each_serializer: JobRequestSerializer, meta: pagination_meta(@job_requests)
  end

  # GET /job_requests/1
  # GET /job_requests/1.json
  def show
    render json: @job_request, serializer: JobRequestSerializer, root: :job_request, ar: params[:ar]
  end

  # POST /job_requests
  # POST /job_requests.json
  # @cleve: status_approval_one sent/approve/reject/nil & Same for two/three/four/five
  def create
    params[:job_request][:job_attributes][:user_id] = @current_user.id
    @job_request = JobRequest.new(job_request_params)

    if @job_request.save && @job_request.job.add_certificates(params[:job_request][:job_attributes][:certificates]) &&
        @job_request.job.add_skills(params[:job_request][:job_attributes][:skills])
      render json: @job_request
    else
      render json: @job_request.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /job_requests/1
  # PATCH/PUT /job_requests/1.json
  # @Cleve: Here the main method .. send request with the new status of each user.
  # Here you'll change the status of each approver.
  def update
    if @job_request.update(job_request_params) && @job_request.job.add_certificates(params[:job_request][:job_attributes][:certificates]) &&
        @job_request.job.add_skills(params[:job_request][:job_attributes][:skills])
      render json: @job_request
    else
      render json: @job_request.errors, status: :unprocessable_entity
    end
  end


  def request_approval
    if Rails.application.secrets[:REQUISITION_DIRECT_PUBLISH] && @job_request.update(direct_publish_params)
      render json: @job_request
    elsif !Rails.application.secrets[:REQUISITION_DIRECT_PUBLISH] &&  @job_request.update(request_for_approval: true)
      render json: @job_request
    else
      render json: @job_request.errors, status: :unprocessable_entity
    end

  end

  def update_approvers
    if @job_request.update(job_request_approver_params)
      render json: @job_request
    else
      render json: @job_request.errors, status: :unprocessable_entity
    end
  end

  # DELETE /job_requests/1
  # DELETE /job_requests/1.json
  def destroy
    @job_request.update(deleted: true)

    render nothing: true, status: :no_content
  end

  def delete_bulk
    JobRequest.where(id: params[:job_request_ids],
                     job_id: Job.where(user_id: @current_user.id).pluck(:id))
        .find_each { |m| m.update_attribute(:deleted, true) }
    render nothing: true, status: :no_content
  end

  private

  def get_job_request

    if @current_user.is_recruiter? || @current_user.role == 'company_owner'
      # Recruiter or Owner can see all job requests
      job_request = JobRequest.active
    else
      # No Recruiter can see only job requests of their department
      job_request = JobRequest.active.where(hiring_manager_id: HiringManager.where(department_id: @current_user.department.id).pluck(:id))
    end
    job_request
  end

  # Use callbacks to share common setup or constraints between actions.
    def set_job_request
      @job_request = JobRequest.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_request_params

      job_params = params.require(:job_request).permit(:job_id, :hiring_manager_id, :grade_id, :total_number_vacancies,
                                                       :position_id, :budgeted_vacancy_id,
                                            job_attributes:
                                              [:id, :title, :description, :qualifications, :requirements,
                                               :job_status_id, :job_type_id, :start_date, :end_date,
                                               :city_id, :country_id, :sector_id, :functional_area_id, :department_id,
                                               :job_education_id, :job_experience_level_id, :experience_from,
                                               :experience_to, :salary_range_id, :join_date,
                                               :age_group_id, :gender, :marital_status, :visa_status_id,
                                               :notification_type, :license_required, :user_id, :active, :deleted,
                                               :country_required, :city_required, :nationality_required,
                                               :gender_required, :age_required, :years_of_exp_required,
                                               :experience_level_required, :language_required,
                                               :benefit_ids => [],
                                               :geo_group_ids => [], :geo_country_ids => [], :skill_ids => [],
                                               :certificate_ids => [],
                                               :language_ids => []]).deep_merge({job_attributes:{company_id: @current_company.id ,latest_changor_user_id: @current_user.id}})

    if @job_request && @job_request.status_approval_one.blank? &&  @job_request.status_approval_two.blank? && @job_request.status_approval_three.blank? &&
        @job_request.status_approval_four.blank? && @job_request.status_approval_five.blank?
      job_params = job_params.merge!({status_approval_one: 'sent', status_approval_two: 'sent',
                                      status_approval_three: 'sent', status_approval_four: 'sent',
                                      status_approval_five: 'sent', status_approval_final: 'sent', deleted: false})
    end

    job_params

    end

    def job_request_approver_params

      status_approval_final = get_final_appoval_status
      params.require(:job_request).permit(:job_id, :hiring_manager_id, :grade_id, :total_number_vacancies, :status_approval_one,
                                          :status_approval_two, :status_approval_three, :status_approval_four,
                                          :status_approval_five, :date_approval_one, :date_approval_two,
                                          :date_approval_three, :date_approval_four, :date_approval_five,
                                          :rejection_reason_one, :rejection_reason_two, :rejection_reason_three,
                                          :rejection_reason_four, :rejection_reason_five).
          merge!({status_approval_final: status_approval_final})

    end

  # Direct publish No email sent to approvers. All approvers are directly set to true
  def direct_publish_params

    {request_for_approval: true, status_approval_one: JobRequest::APPROVE_STATUS,
     status_approval_two: JobRequest::APPROVE_STATUS,
     status_approval_three: JobRequest::APPROVE_STATUS,
     status_approval_four: JobRequest::APPROVE_STATUS,
     status_approval_five: JobRequest::APPROVE_STATUS,
     status_approval_final: JobRequest::APPROVE_STATUS,
     date_approval_one: Date.today,
     date_approval_two: Date.today,
     date_approval_three: Date.today,
     date_approval_four: Date.today,
     date_approval_five: Date.today
    }
  end


  def get_final_appoval_status

    num_approvers = @job_request.hiring_manager.num_approvers

    if (params[:status_approval_one] == JobRequest::APPROVE_STATUS || @job_request.status_approval_one == JobRequest::APPROVE_STATUS) &&
        ((params[:status_approval_two] == JobRequest::APPROVE_STATUS || @job_request.status_approval_two == JobRequest::APPROVE_STATUS)  || num_approvers < 2) &&
        ((params[:status_approval_three] == JobRequest::APPROVE_STATUS || @job_request.status_approval_three == JobRequest::APPROVE_STATUS)  || num_approvers < 3) &&
        ((params[:status_approval_four] == JobRequest::APPROVE_STATUS || @job_request.status_approval_four == JobRequest::APPROVE_STATUS) || num_approvers < 4) &&
        ((params[:status_approval_four] == JobRequest::APPROVE_STATUS || @job_request.status_approval_four == JobRequest::APPROVE_STATUS) || num_approvers < 5)

        # All Approvers have approved
        JobRequest::APPROVE_STATUS

    elsif [params[:status_approval_one], params[:status_approval_two], params[:status_approval_three], params[:status_approval_four]].include?(JobRequest::REJECT_STATUS)
      # Any one Approver have rejected
      JobRequest::REJECT_STATUS
    else
      JobRequest::SENT_STATUS
    end

  end

  def set_approval_date
    valid_approver = false
    approvers = %w(one two three four five)
    approvers.each_with_index do |sel_approver, index|
      if params[:job_request]["status_approval"].present? &&
          @job_request.hiring_manager.send("approver_#{sel_approver}").try(:id) == @current_user.id &&
          @job_request.request_for_approval

        # Checking if previous Approver has already approved
        if index == 0 || @job_request.send("status_approval_#{approvers[index - 1]}") == 'approved'

          valid_approver = true
          params.require(:job_request).merge!({"status_approval_#{sel_approver}": params[:job_request][:status_approval],
                                               "date_approval_#{sel_approver}": Date.today,
                                               "rejection_reason_#{sel_approver}": params[:job_request][:rejection_reason]}) if params[:job_request][:status_approval].present?
        end


      end
    end
    reject_job_requisition_approver if !valid_approver
  end

  def reject_job_requisition_approver
    @current_ability.cannot params[:action].to_sym, JobRequest
    authorize!(params[:action].to_sym, JobRequest)
  end
end


