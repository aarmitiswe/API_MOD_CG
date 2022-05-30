class Api::V1::JobApplicationStatusChangesController < ApplicationController
  #before_action :check_permissions, only: [:create_bulk, :create, :create_offer_letter]
  before_action :set_job_application, only: [:index]
  before_action :check_recruiter_permissions, only: [:create, :update]
  before_action :set_job, only: [:create_bulk, :create_bulk_status_change, :create_bulk_status_change_on_search_criteria]
  before_action :job_application_owner, except: [:create_bulk, :create_bulk_status_change, :create_bulk_status_change_on_search_criteria]

  # GET /job_application_status_changes
  # GET /job_application_status_changes.json
  def index
    @job_application_status_changes = JobApplicationStatusChange.order(created_at: :desc).where(job_application_id: @job_application.id)
    render json: @job_application_status_changes, each_serializer: JobApplicationStatusChangeSerializer, ar: params[:ar]
  end

  # POST /job_application_status_changes
  # POST /job_application_status_changes.json
  # params: {job_application_status_change: {comment: "", job_application_status_id: 1, jobseeker_id: 1,
  # interview_attributes: {}, offer_letter_attributes: {document: File, document_attributes: {join_date: "", title: "", content: ""}}}}
  def create

    if params[:job_application_status_change][:interview_attributes] &&
        Rails.application.secrets['INTERVIEW_COMMITTEE']
      create_multi_interview
    else
      @job_application_status_change = JobApplicationStatusChange.new(job_application_status_change_params)

      if @job_application_status_change.save

        File.delete(@save_path) unless @save_path.blank?


        render json: @job_application_status_change, serializer: JobApplicationStatusChangeSerializer, ar: params[:ar]
      else
        render json: @job_application_status_change.errors, status: :unprocessable_entity
      end
    end
  end



  def update
    if @job_application_status_change.update(job_application_status_change_params)
      render json: @job_application_status_change, serializer: JobApplicationStatusChangeSerializer, ar: params[:ar]
    else
      render json: @job_application_status_change.errors, status: :unprocessable_entity
    end
  end

  def create_offer_letter
    @job_application_status_change = JobApplicationStatusChange.new(job_application_status_change_params)

    if @job_application_status_change.save
      File.delete(@save_path) unless @save_path.blank?
      render json: @job_application_status_change, serializer: JobApplicationStatusChangeSerializer, ar: params[:ar]
    else
      render json: @job_application_status_change.errors, status: :unprocessable_entity
    end
  end


  # params: {job_application_status_change: {comment: "", job_application_status_id: 1}, start_matching_percentage: 20,
  # end_matching_percentage: 70}
  def create_bulk
    @users_jobseeker = Job.applicants_in_range @job,
                                               params[:start_matching_percentage],
                                               params[:end_matching_percentage]
    @job_application_status_changes = []
    @job_application_status_changes_errors = []

    @users_jobseeker.each do |user_jobseeker|
      @job_application_status_change = JobApplicationStatusChange.new(job_application_status_change_params_bulk user_jobseeker)

      if @job_application_status_change.save
        sleep 1
        @job_application_status_changes.push @job_application_status_change
      else
        @job_application_status_changes_errors.push @job_application_status_change.errors
      end
    end

    render json: {success_change: @job_application_status_changes, error_change: @job_application_status_changes_errors}
  end


  def create_bulk_status_change
    @users_jobseeker = Jobseeker.ransack(params[:q]).result
    @job_application_status_changes = []
    @job_application_status_changes_errors = []
    @users_jobseeker.each do |user_jobseeker|
      @job_application_status_change = JobApplicationStatusChange.new(job_application_status_change_params_bulk user_jobseeker)

      if @job_application_status_change.save
        sleep 1
        @job_application_status_changes.push @job_application_status_change
      else
        @job_application_status_changes_errors.push @job_application_status_change.errors
      end
    end

    render json: {success_change: @job_application_status_changes, error_change: @job_application_status_changes_errors}
  end

  def create_bulk_status_change_on_search_criteria
    jobseeker_ids = get_jobseeker_ids_on_search
    @users_jobseeker = Jobseeker.where(id: jobseeker_ids)

    @job_application_status_changes = []
    @job_application_status_changes_errors = []
    @users_jobseeker.each do |user_jobseeker|
      @job_application_status_change = JobApplicationStatusChange.new(job_application_status_change_params_bulk user_jobseeker)

      if @job_application_status_change.save
        sleep 1
        @job_application_status_changes.push @job_application_status_change
      else
        @job_application_status_changes_errors.push @job_application_status_change.errors
      end
    end

    render json: {success_change: @job_application_status_changes, error_change: @job_application_status_changes_errors}
  end

  def get_interviews
    render json: @job_application_status_change.interviews, root: :interviews

  end

  private

  def create_multi_interview
    begin
      ActiveRecord::Base.transaction do
        interview_params = job_application_status_change_params
        interview_params[:interview_attributes][:interviewer_id] =
            params[:job_application_status_change][:interview_attributes][:interviewer_ids][0]
        @job_application_status_change = JobApplicationStatusChange.new(interview_params)
        if @job_application_status_change.save
          if !@job_application_status_change.interviews.blank? &&
              params[:job_application_status_change][:interview_attributes][:interviewer_ids]
            interviewer_ids = params[:job_application_status_change][:interview_attributes][:interviewer_ids]
            interviewer_ids.each do |sel_interview_id|
              interviewCommitteeMember = InterviewCommitteeMember.new(
                  interview_id: @job_application_status_change.interviews.last.id, user_id: sel_interview_id)
              raise ActiveRecord::Rollback if !interviewCommitteeMember.save
            end

          end
          File.delete(@save_path) unless @save_path.blank?
          render json: @job_application_status_change, serializer: JobApplicationStatusChangeSerializer, ar: params[:ar]
        else
          render json: @job_application_status_change.errors, status: :unprocessable_entity
        end
      end
    rescue ActiveRecord::InvalidForeignKey
      render json: 'Invalid User Id'
    end
  end

  def set_job
      @job = Job.find_by_id(params[:job_id])
    end

    def get_jobseeker_ids_on_search
      params[:gp] ||= false

      if params[:gp]
        # Applicants for Graduate Program

        @applicants_ids = Jobseeker.where(id: JobApplication.where(job_id: @job.id).ransack(params[:q]).result.distinct(true).pluck(:jobseeker_id)).ransack(params[:q]).result.pluck(:id)
        params_except_je_in = (params[:q]) ? params[:q].except(:je_in) : params[:q]
        @applicants_ids_edu = Jobseeker.where(id: JobseekerEducation.ransack(params_except_je_in).result.distinct(true).pluck(:jobseeker_id)).ransack(params[:q]).result.pluck(:id)

        @applicants_ids_gp = Jobseeker.where(id: JobseekerGraduateProgram.matched_criteria.ransack(params[:q]).result.distinct(true).pluck(:jobseeker_id)).ransack(params[:q]).result.pluck(:id)
        @applicants_ids = @applicants_ids & @applicants_ids_gp & @applicants_ids_edu

      elsif Rails.application.secrets[:ACTIVATE_REQUISITION]
        # Applicants for Requisition

        # All Candidates that applied
        applied_jobseeker_ids = JobApplication.where(job_id: @job.id).ransack(params[:q]).result.distinct(true).pluck(:jobseeker_id)

        # Jobseeker who match search criteria
        applied_jobseeker_ids = jobseeker_selection_criteria(applied_jobseeker_ids)

        @applicants_ids = Jobseeker.where(id: applied_jobseeker_ids).ransack(params[:q]).result.pluck(:id)

      else
        # Regular Applicants
        @applicants_ids = Jobseeker.where(id: JobApplication.where(job_id: @job.id).ransack(params[:q]).result.distinct(true).pluck(:jobseeker_id)).ransack(params[:q]).result.pluck(:id)
        params_except_je_in = (params[:q]) ? params[:q].except(:je_in) : params[:q]
        @applicants_ids_edu = Jobseeker.where(id: JobseekerEducation.ransack(params_except_je_in).result.distinct(true).pluck(:jobseeker_id)).ransack(params[:q]).result.pluck(:id)
        @applicants_ids = @applicants_ids  & @applicants_ids_edu

      end

      # Special Search For Email Id, Phone number and Ref Number
      if params[:email] || params[:ref_id]

        params[:q] = {email_in: params[:email], id_in: params[:ref_id]}

        @applicants_ids_user = Jobseeker.where(user_id: User.ransack(params[:q]).result.distinct(true).pluck(:id)).pluck(:id)
        @applicants_ids = @applicants_ids & @applicants_ids_user
      end

      @applicants_ids
    end

   def jobseeker_selection_criteria(applied_jobseeker_ids)
    if @job.country_required
      applied_jobseeker_ids = Jobseeker.where(current_country_id: @job.country_id, id: applied_jobseeker_ids).pluck(:id)
    end

    # Jobseeker who have same city as Job
    if @job.city_required
      applied_jobseeker_ids = Jobseeker.where(current_city_id: @job.city_id, id: applied_jobseeker_ids).pluck(:id)
    end

    # Jobseeker who have same nationality as Job
    if @job.nationality_required
      applied_jobseeker_ids = Jobseeker.where(nationality_id: @job.geo_country_ids, id: applied_jobseeker_ids).pluck(:id)
    end

    # Jobseeker who have same gender as Job
    if @job.gender_required && !@job.gender.blank?
      applied_jobseeker_ids = Jobseeker.where(id: applied_jobseeker_ids).gender(@job.gender).pluck(:id)
    end

    # Jobseeker who have same age as Job
    if @job.age_required && !@job.age_group_id.blank?
      applied_jobseeker_ids = Jobseeker.age(@job.age_group.min_age, @job.age_group.max_age).where(id: applied_jobseeker_ids).pluck(:id)
    end

    # Jobseeker who have same experience as Job
    if @job.years_of_exp_required
      applied_jobseeker_ids = Jobseeker.where("years_of_experience >= ? AND years_of_experience <= ?", @job.experience_from, @job.experience_to).where(id: applied_jobseeker_ids).pluck(:id)
    end


    # Jobseeker who have same Experience Level as Job
    if @job.experience_level_required
      applied_jobseeker_ids = Jobseeker.where(job_experience_level_id: @job.job_experience_level_id).where(id: applied_jobseeker_ids).pluck(:id)
    end

    # Jobseeker who have same language as Job
    if @job.language_required
      applied_jobseeker_ids = JobseekerLanguage.where(language_id: @job.language_ids, jobseeker_id: applied_jobseeker_ids).pluck(:jobseeker_id)
    end
    applied_jobseeker_ids
  end

    def check_permissions
      # Validation if only permission to create interview or shortlist or Offer
      interview_only = (@current_user.permissions.interview_only.count > 0)
      shortlist_only = (@current_user.permissions.shortlist_only.count > 0)
      offer_only = (@current_user.permissions.offer_only.count > 0)
      if interview_only || shortlist_only || offer_only
        can_shortlist = false
        can_interview = false
        can_offer = false

        # Validate Shortlisting
        if shortlist_only && JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS['Shortlisted']).id ==
            params[:job_application_status_change][:job_application_status_id].to_i
          can_shortlist = true
        end

        # Validate Interview
        if interview_only && JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS['Interview']).id ==
            params[:job_application_status_change][:job_application_status_id].to_i
          can_interview = true
        end

        # Validate Successful
        if offer_only && JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS['Successful']).id ==
            params[:job_application_status_change][:job_application_status_id].to_i
          can_offer = true
        end

        if !can_shortlist && !can_interview && !can_offer
          reject_action
        end
      end
    end

    def set_job_application
      @job_application = @current_company.job_applications.find_by_id(params[:job_application_id])
      @jobseeker = @job_application.try(:jobseeker)
    end

    def job_application_status_change_params
      update_params

      params.require(:job_application_status_change).permit(:comment, :notify_jobseeker, :job_application_status_id, :on_boarding_status, :watheeq, :performance_evaluation, :on_boarding_session, :offer_requisition_status,
                                                            :it_management, :business_service_management, :security_management,
                                                            interviews_attributes: [:id,:appointment, :time_zone, :comment,
                                                                                   :channel, :contact, :status,
                                                                                   :interviewee, :interviewer_designation,
                                                                                   :duration, :employer_zone, :is_approved,
                                                                                   :interviewer_id, :interview_status, :is_selected, :_destroy],
                                                            candidate_information_document_attributes: [:id, :title, :document, :document_two,
                                                                                                        :document_three, :document_four, :document_report,
                                                                                                        :name, :id_number,
                                                                                                        :document_national_address, :document_edu_cert,
                                                                                                        :document_training_cert, :document_passport,
                                                                                                        :job_title, :job_grade, :agency_id, :current_employer,
                                                                                                        :is_deleted, :default,
                                                                                                        :job_application_id],
                                                            assessments_attributes: [:id, :assessment_type, :status, :comment, :document_report],
                                                            offer_letters_attributes: [:id, :document, :joining_date, :shared_to_stc_at, :sent_to_candidate_at, :received_from_stc_at, :jobseeker_status, :candidate_dob,
                                                                                       :candidate_second_name, :candidate_third_name, :candidate_birth_city, :candidate_birth_country, :candidate_nationality,
                                                                                       :candidate_religion, :candidate_gender,  :_destroy])
          .merge!({employer_id: @current_user.id, job_application_id: params[:job_application_id], jobseeker_id: @jobseeker.user.id})
    end

    def job_application_status_change_params_bulk user_jobseeker
      set_job
      job_application = JobApplication.find_by(job_id: @job.id, jobseeker_id: user_jobseeker.id)

      params.require(:job_application_status_change).permit(:comment, :notify_jobseeker, :job_application_status_id, :candidate_ids)
          .merge!({employer_id: @current_user.id, job_application_id: job_application.try(:id),
                   jobseeker_id: user_jobseeker.user_id})

    end

    # This action to update params if generate offer letter
    def update_params
      # Set Job Application
      set_job_application
      if Rails.application.secrets['OFFER_LETTERS']['neom']
        neom_offer_letter
      else
        core_offer_letter
      end

    end

  def neom_offer_letter
    if !params[:job_application_status_change][:offer_letter_attributes].nil? &&
        params[:job_application_status_change][:offer_letter_attributes][:document].nil?

      pdf = render_to_string pdf: "generate_offer_letter", file: "api/v1/job_application_status_changes/generate_offer_letter_neom",
                             handlers: [:erb], formats: [:html], encoding: "UTF-8"

      @save_path = Rails.root.join('pdfs', "offer_letter_#{Time.now.to_formatted_s(:number)}.pdf")
      file_obj = File.open(@save_path, 'wb') do |file|
        file << pdf
      end
      file_obj.close
      params[:job_application_status_change][:offer_letter_attributes][:document] = File.open(@save_path)
      params[:job_application_status_change][:offer_letter_attributes].delete(:title)
      params[:job_application_status_change][:offer_letter_attributes].delete(:content)
      params[:job_application_status_change][:offer_letter_attributes].delete(:basic_salary)
      params[:job_application_status_change][:offer_letter_attributes].delete(:housing_salary)
      params[:job_application_status_change][:offer_letter_attributes].delete(:transportation_salary)
      params[:job_application_status_change][:offer_letter_attributes].delete(:mobile_allowance_salary)
      params[:job_application_status_change][:offer_letter_attributes].delete(:total_salary)
    end
  end

  def core_offer_letter
    if !params[:job_application_status_change][:offer_letter_attributes].nil? &&
        params[:job_application_status_change][:offer_letter_attributes][:document].nil?

      pdf = render_to_string pdf: "generate_offer_letter", file: "api/v1/job_application_status_changes/generate_offer_letter",
                             handlers: [:erb], formats: [:html], encoding: "UTF-8"

      @save_path = Rails.root.join('pdfs', "offer_letter_#{Time.now.to_formatted_s(:number)}.pdf")
      file_obj = File.open(@save_path, 'wb') do |file|
        file << pdf
      end
      file_obj.close
      params[:job_application_status_change][:offer_letter_attributes][:document] = File.open(@save_path)
      params[:job_application_status_change][:offer_letter_attributes].delete(:title)
      params[:job_application_status_change][:offer_letter_attributes].delete(:content)
    end
  end

  def job_application_owner
      if params[:job_application_id].nil? || !@current_company.job_applications.map(&:id).include?(params[:job_application_id].to_i)
        reject_action
      end
  end

  def check_recruiter_permissions
    set_job_application if @job_application.blank?
    if @current_user.is_recruiter && !@current_user.has_permission_to_job(@job_application.job)
      reject_action
    end
  end

  def reject_action
    @current_ability.cannot params[:action].to_sym, JobApplicationStatusChange
    authorize!(params[:action].to_sym, JobApplicationStatusChange)
  end
end
