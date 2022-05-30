class Api::V1::JobApplicationsController < ApplicationController
  # before_action :set_user
  # before_action :jobseeker_owner
  before_action :set_job_application, only: [:create_salary_offer_analysis, :approve_all_evaluation_submits, :update_extra_document, :download_history,  :destroy, :all_documents]

  before_action :check_recruiter_permissions, only: [:create_bulk, :destroy]
  # GET /job_applications
  # GET /job_applications.json
  # Jobseeker JobApplications
  def index
    params[:q] ||= {}
    @q = @current_user.is_jobseeker? ? @current_user.jobseeker.job_applications.not_deleted.ransack(params[:q]) : JobApplication.ransack(params[:q])
    @job_applications = @q.result.paginate(page: params[:page])
    render json: @job_applications, each_serializer: JobApplicationSerializer, root: :job_applications, ar: params[:ar], meta: pagination_meta(@job_applications)
  end

  def show
    @job_application = if params[:id]
                         JobApplication.find_by_id(params[:id])
                       elsif params[:job_id] && params[:jobseeker_id]
                         JobApplication.find_by(job_id: params[:job_id], jobseeker_id: params[:jobseeker_id])
                       end

    render json: @job_application, serializer: JobApplicationSerializer, root: :job_applications, ar: params[:ar]
  end

  # POST /job_applications
  # POST /job_applications.json
  # Apply for Job by Jobseeker
  # def create
  #   @job_application = @jobseeker.job_applications.new(job_application_params)
  #
  #   if @job_application.save
  #     render json: @job_application, serializer: JobApplicationSerializer, root: :job_application, ar: params[:ar]
  #   else
  #     render json: @job_application.errors, status: :unprocessable_entity
  #   end
  # end

  # POST /job_applications/create_bulk
  def create_bulk
    jobseeker_ids = params[:job_application][:jobseeker_ids]
    job_id = params[:job_application][:job_id]
    candidate_type = params[:job_application][:candidate_type]
    employment_type = params[:job_application][:employment_type]
    job_application_status_id = 1
    employer_id = @current_user.id

    # Check if jobseeker has an existing application in progress 
    if jobseeker_ids.count === 1
      jobseeker = Jobseeker.find(jobseeker_ids[0])
      if !jobseeker.nil?
        existing_applications = jobseeker.job_applications && jobseeker.job_applications.not_deleted
        existing_applications.each do |application|
          if !['succsessful', 'unsuccessful'].include?(application.job_application_status.status.downcase)
            render json: { error: "user_has_inprogress_application" }, status: :unprocessable_entity and return
          end
        end
      end
    end

    @job_applications = JobApplication.create_bulk(jobseeker_ids, job_id, job_application_status_id, employer_id, employment_type, candidate_type, @current_user.id)
    #render json: @job_applications, each_serializer: JobApplicationSerializer, root: :job_applications, ar: params[:ar], meta: pagination_meta(@job_applications)
    render json: @job_applications, each_serializer: JobApplicationSerializer, root: :job_applications, ar: params[:ar]
  end

  # PUT /job_applications/:id/update_extra_document
  def update_extra_document
    if @job_application.update(job_application_extra_document_params)
      render json: @job_application, serializer: JobApplicationSerializer, root: :job_applications, ar: params[:ar]
    else
      render json: @job_application.errors, status: :unprocessable_entity
    end
  end

  def download_history
    respond_to do |format|
      format.html
      format.json { send_data( @job_application.export_history_to_csv, :filename => "#{@job_application.id}_application_history_#{Date.today}.csv" ) }
    end
  end

  def approve_all_evaluation_submits
    @evaluation_submits = @job_application.evaluation_submits
    @evaluation_submit_requisitions = EvaluationSubmitRequisition.where(evaluation_submit_id: @evaluation_submits.pluck(:id)).where(user_id: @current_user.id)
    @evaluation_submit_requisitions.update_all(status: 'approved')
    @evaluation_submit_requisitions.each do |r|
      next_one = r.get_next_requisition
      next_one.update_column(:active, true) if next_one.present?
    end
    @evaluation_submit_requisitions.last.check_next_requisition
    render json: @evaluation_submits, each_serializer: EvaluationSubmitSerializer
  end

  def update_terminate_status
    @jobseeker = User.find_by(oracle_id: params[:oracle_id]).try(:jobseeker) || Jobseeker.find_by(oracle_id: params[:oracle_id])

    # Only last application of this jobseeker for a job created using the given position will be terminated
    # if ejada team can send the job_id from mod system during termination then the above issue will be solved
    @job_application = JobApplication.where(jobseeker_id: @jobseeker.try(:id), job_id: Position.find_by_oracle_id(params[:job_id]).try(:jobs).try(:pluck,:id)).last

    if @job_application.nil?
      render json: {errors: {job_application: 'Not Found'}}, status: :not_found
    else
        @job_application.update(terminated_at: DateTime.now)
        @job_application.job.update(job_status_id: JobStatus.find_by(status: 'Open').try(:id)) if @job_application.job.job_status_id == JobStatus.find_by(status: 'Closed').try(:id)
        @job_application.job_application_status_changes.create({comment: "Moved to unsuccessful by oracle system",
                                                                job_application_status_id: JobApplicationStatus.find_by_status("Unsuccessful").id,
                                                                employer_id: @current_user.id,
                                                                jobseeker_id: @jobseeker.user.id}) if !@job_application.is_unsuccessful?
        # @job_application.job.position.unlock_position
        render json: @job_application, serializer: JobApplicationSerializer, ar: params[:ar]
    end
  end



#   def share_hiring_managers
#
#     # Params
#     job_id = params[:job_id]
#     applicant_ids = params[:applicant_ids]
#
#     # Get hiring manager of job
#     job = Job.find(job_id)
#     hiring_manager_id = job.user_id
#     hiring_manager = User.find(hiring_manager_id)
#
#     # Update job application
#     applications = JobApplication.where(job_id: params[:job_id], :jobseeker_id => params[:applicant_ids])
#     applications.each do |app|
#       app.update(shared_with_hiring_manager: true)
#     end
#
#     # Send Notification
#     template_values = {
#       User: hiring_manager.first_name,
#       HiringManagerName: "#{hiring_manager.first_name} #{hiring_manager.last_name}",
#       RecruiterName: "#{@current_user.first_name} #{@current_user.last_name}",
#       JobTitle: job.title,
#       CompanyName: "MOD",
#       ArCompanyName: "وزارة الدفاع",
#       primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
#       secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
#       lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
#       borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
#       Website: Rails.application.secrets[:ATS_NAME]["website_name"],
#       CompanyImg: "",
#       CreateDate: Time.now.strftime("%d %b, %Y"),
#     }
#
#     hiring_manager.send_email "upload_candidate_by_hiring_manager",
#                               [{email: hiring_manager.email, name: hiring_manager.first_name}],
#                               {message_body: nil, template_values: template_values}
#
# #    render json: {status: 200, applicant_id: params[:applicant_id]}
#
#     render json: { message: "shared" }, status: :ok
#   end

  def init_security_clearance

    # Get job application
    @job_application = JobApplication.find(params[:job_application_id])

    # Security Clearance pdf
    pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/security_clearance/security_clearance.html.erb", layout: false, encoding: 'utf8')
    )
    security_clearance_url = "system/security_clearance/security_clearance_#{params[:job_application_id]}.pdf"
    File.open('public/'+security_clearance_url, "wb") do |file|
      file.write(pdf)
    end
    @job_application.security_clearance_document = security_clearance_url

    # # Candidate Information Document
    # if params[:candidate_information_document].present?
    #   candidate_information_document = CandidateInformationDocument.new(candidate_information_document_params)
    #   if candidate_information_document.valid?
    #     candidate_information_document.save
    #     @job_application.candidate_information_document_id = candidate_information_document.id
    #   end
    # end

    # Save job application
    if @job_application.valid?
      @job_application.save
    end

    render json: @job_application

  end

  def generate_hiring_contract
    render template: 'api/v1/job_applications/generate_hiring_contract.html.erb', pdf: 'sample_contract', handlers: [:erb], formats: [:html]
  end

  def security_clearance_result
    is_security_cleared = params[:is_security_cleared]
    @job_application = JobApplication.find(params[:job_application_id])
    @job_application.is_security_cleared = is_security_cleared

    # Security Clearance Result Document
    if params[:security_clearance_result_document].present?
      security_clearance_result_document = CandidateInformationDocument.new(security_clearance_result_document_params)
      if securiy_clearance_result_document.valid?
        securiy_clearance_result_document.save
        @job_application.security_clearance_result_document_id = security_clearance_result_document.id
      end
    end

    # Save job application
    @job_application.save

    render json: @job_application
  end

  def all_documents
    document_list = @job_application.get_all_documents
    render json: {all_documents: document_list}, status: 200
  end

  def scan_medical_insurance
    if params
      dependents_list = JobApplication.scan_medical_insurance params
      render json: {dependents: dependents_list}, status: 200
    else
      render json: {error: 'invalid_document'}, status: :unprocessable_entity
    end
  end

  def create_salary_offer_analysis
    @offer_analysis = OfferAnalysis.new(offer_analysis_params)
    @salary_analysis = SalaryAnalysis.new(salary_analysis_params)
    @offer_analysis.user_id = @current_user.id
    if @job_application.job_application_status_changes.job_offer.blank?

      last_change = @job_application.job_application_status_changes.last
      @job_application.job_application_status_changes.create(job_application_status_id: JobApplicationStatus.find_by_status('JobOffer').id,
                                                             employer_id: @current_user.id, jobseeker_id: last_change.jobseeker_id)
    end

    if @salary_analysis.save && @offer_analysis.save
      render json: @job_application, serializer: JobApplicationWithSalaryAndOfferSerializer
    else
      render json: (@offer_analysis.errors + @salary_analysis.errors), status: :unprocessable_entity
    end
  end

  def destroy
    @job_application.delete_application(@current_user)
    render nothing: true, status: 204
  end


  private
    # def set_user
    #   @jobseeker = User.find_by_id(params[:jobseeker_id]).try(:jobseeker)
    # end

    def set_job_application
      @job_application = JobApplication.not_deleted.find(params[:id])
    end

    def candidate_information_document_params
      params.require(:candidate_information_document).permit(:id, :title, :document, :is_deleted, :default, :job_application_id)
    end

    def security_clearance_result_document_params
      params.require(:candidate_information_document).permit(:id, :title, :document, :is_deleted, :default, :job_application_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def offer_analysis_params
      params.require(:offer_analysis).permit(:basic_salary, :housing_allowance, :transportation_allowance,
                                             :monthly_salary).merge!(job_application_id: @job_application.id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def salary_analysis_params
      params.require(:salary_analysis).permit(:basic_salary, :housing_allowance,
                                              :transportation_allowance, :special_allowance, :ticket_allowance,
                                              :education_allowance, :incentives, :monthly_salary, :level).merge!(job_application_id: @job_application.id)
    end

    # job_application_status_id is override on create by callback method
    def job_application_params
      params.require(:job_application).permit(:jobseeker_id, :job_id, :job_application_status_id,
                                              :jobseeker_coverletter_id, :jobseeker_resume_id, :terminated_at,
                                      candidate_information_documents_attributes: [:id, :title, :document, :is_deleted, :default, :_destroy],
                                             )
    end

    def job_application_extra_document_params
      params.require(:job_application).permit(:extra_document, :extra_document_title)
    end

   def check_recruiter_permissions
     if @current_user.is_recruiter
       if @job_application  && !@current_user.has_permission_to_job(@job_application.job)
         reject_action
       elsif params[:job_application] && params[:job_application][:job_id] && !@current_user.has_permission_to_job(Job.find(params[:job_application][:job_id]))
         reject_action
       end
     end
   end

  def reject_action
    @current_ability.cannot params[:action].to_sym, JobApplicationStatus
    authorize!(params[:action].to_sym, JobApplicationStatus)
  end

    def jobseeker_owner
      if @current_user.is_jobseeker? && (params[:jobseeker_id].nil? || @current_user.id != params[:jobseeker_id].to_i)
        @current_ability.cannot params[:action].to_sym, JobApplication
        authorize!(params[:action].to_sym, JobApplication)
      end
    end
end
