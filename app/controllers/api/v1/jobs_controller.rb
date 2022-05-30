class Api::V1::JobsController < ApplicationController
  include AdjustSearchParamsHelper
  #before_action :check_permissions_update, only: [:update]
  #before_action :check_permissions_destroy, only: [:destroy]

  skip_before_action :authenticate_user, only: [:index, :show, :statistics]
  before_action :set_job, only: [:update, :destroy, :similar_jobs,
                                 :similar_companies, :analysis, :statistics, :get_filters_with_applicants_count,
                                 :get_filters_with_applicants_count_gp, :export_candidates, :employment_type]

  before_action :job_owner, only: [:update, :destroy, :applicants, :suggested_jobseekers, :job_applications_analysis,
                                   :job_applications_analysis_gp, :applicants_export_csv,
                                   :applicants_export_csv_gp_junk]

  before_action :update_search_params, only: [:applicants, :suggested_jobseekers]

  # GET /jobs
  # GET /jobs.json
  def index
    if params[:query]
      params[:q] ||= {}
      params[:q][:title_or_description_or_requirements_cont] = params[:query]
      # params[:q][:description_cont] = params[:query]
      # params[:q][:m] = 'or'
    end
    per_page = params[:all].blank? ? (params[:per_page] || Job.per_page) : Job.count
    if params[:q] && params[:q][:organization_id_in]
      organizations = Organization.where(id: params[:q][:organization_id_in])
      all_orgnaizations_ids = organizations.map{ |org| org.all_children_organizations.map(&:id) }.flatten
      params[:q][:organization_id_in] = all_orgnaizations_ids
    end

    job_ids = @current_user.accessable_job_ids if @current_user.present?

    @q = if job_ids.blank?
           Job.order(approved_at: :desc).ransack(params[:q])
         else
           Job.order(approved_at: :desc).where(id: job_ids).ransack(params[:q])
         end
    # if @current_user.is_job_offer_approver?
    #   params[:q][:id_in] = JobApplication.job_offer.pluck(:job_id)
    # end
    #
    #
    # @q = if @current_user.present? && @current_user.is_interviewer?
    #        Job.where(id: InterviewCommitteeMember.where(user_id: @current_user.id).map{|i| i.interview.job.id}).order(created_at: :desc).ransack(params[:q])
    #      elsif @current_user.is_assessor? || @current_user.is_assessor_coordinator?
    #        Job.assessor_jobs.where(id: JobApplication.assessment.pluck(:job_id)).ransack(params[:q])
    #      elsif @current_user.is_qec_coordinator?
    #        Job.where(id: JobApplication.assessment.pluck(:job_id)).ransack(params[:q])
    #      elsif @current_user.is_security_clearance_officer?
    #        Job.where(id: JobApplication.security_clearance.pluck(:job_id)).ransack(params[:q])
    #      elsif @current_user.is_hiring_manager?
    #        Job.where(organization_id: @current_user.all_organization_ids).order(created_at: :desc).ransack(params[:q])
    #      elsif Role.where(name: Role::ON_BOARDING_ROLES).map(&:id).include?(@current_user.role_id)
    #        Job.where(id: JobApplication.onboarding.pluck(:job_id)).ransack(params[:q])
    #      else
    #        Job.order(created_at: :desc).ransack(params[:q])
    #      end
    @jobs = @q.result.includes(:organization).paginate(page: params[:page], per_page: per_page)
    # render json: @jobs, meta: pagination_meta(@jobs), each_serializer: JobListSerializer
    respond_to do |format|
      format.json { render json: @jobs, meta: pagination_meta(@jobs),
                           each_serializer: params[:mini]? JobAuthorizedMiniSerializer :  JobAuthorizedSerializer, ar: params[:ar] }
      format.xml
    end
  end

  # GET /jobs/my_jobs
  # GET /jobs/my_jobs.json
  def my_jobs
    per_page = params[:all].blank? ? (params[:per_page] || Job.per_page) : Job.count
    @q = Job.where(user_id: @current_user.id).approved.order(created_at: :desc).ransack(params[:q])
    @jobs = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @jobs, meta: pagination_meta(@jobs), each_serializer: JobAuthorizedSerializer, ar: params[:ar]
  end

  # GET /jobs/1
  # GET /jobs/1.json
  # Public Jobs View Details only if active - Public Requests
  def show
    @job = Job.active.internal_hiring(@current_user).find_by_id(params[:id])
    if @job
      @job.increase_viewers
      render json: @job, serializer: (employer_signed_in?) ? JobAuthorizedSerializer : JobSerializer, root: :job, ar: params[:ar]
    else
      render json: {errors: {job: 'Not Found'}}, status: :not_found
    end
  end

  # For Authorized requests
  def show_details
    @job = if @current_user.is_jobseeker?
              Job.active.internal_hiring(@current_user).find_by_id(params[:id])
           else
              @current_company.jobs.find_by_id(params[:id])
           end

    if @job
      if @current_user.is_jobseeker?
        @job.increase_viewers
        @job = Job.add_matching_percentage @current_user.jobseeker, @job
      end

      render json: @job, serializer: JobAuthorizedSerializer, root: :job, ar: params[:ar]
    else
      render json: {errors: {job: 'Not Found'}}, status: :not_found
    end
  end


  def get_application_stage_count
    params[:application_status] ||= "Assessment"
    status_count = JobApplicationStatusChange.where(job_application_status_id: JobApplicationStatus.find_by_status(params[:application_status]).id).where(job_application_id: JobApplication.where(job_id: @job.id).pluck(:id)).count
    if status_count
      render json: {count: status_count}, status: 200
    end
  end

  def show_details_pdf
    @job = Job.find_by_id(params[:id])

    render pdf: 'job_requisition', handlers: [:erb], formats: [:html]
  end

  def statistics
    render json: @job, serializer: JobCountingDetailsSerializer, root: :job, ar: params[:ar]
  end

  def analysis
    render json: @job, serializer: JobAnalysisSerializer, root: :job, ar: params[:ar]
  end

  def similar_jobs
    @jobs = @job.similar_jobs
    render json: @jobs, each_serializer: JobListSerializer, root: :similar_jobs, ar: params[:ar]
  end

  def similar_companies
    @similar_companies = @job.similar_companies
    render json: @similar_companies, each_serializer: CompanyListSerializer, root: :similar_companies, ar: params[:ar]
  end

  def similar_careers
    render json: @job, serializer: SimilarCareersSerializer, root: :job, ar: params[:ar]
  end

  def share_url
    if @job.share_url share_params
      render nothing: true, status: 204
    else
      render json: @job.errors, status: :unprocessable_entity
    end
  end

  # POST /jobs
  # POST /jobs.json
  def create
    params[:job][:user_id] = @current_user.id
    params[:job][:job_education_id] = nil

    @job = @current_company.jobs.new(job_params)
    if @job.is_sent? && @job.save(validate: false) && @job.add_certificates(params[:job][:certificates]) && @job.add_skills(params[:job][:skills])
      render json: @job, serializer: JobAuthorizedSerializer, root: :job
    elsif @job.save && @job.add_certificates(params[:job][:certificates]) && @job.add_skills(params[:job][:skills])
      @bloovo_mailer = BloovoMailer.new
      #@bloovo_mailer.send_followers_notification(@job.company) unless @job.notified
      render json: @job, serializer: JobAuthorizedSerializer, root: :job, ar: params[:ar]
    else
      render json: @job.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    # Activate & De Activate Permisssion allow only job status change
    act_deact_only = (@current_user.permissions.activate_deactivate_job.count > 0)
    sel_job_params = (act_deact_only)? job_params_status_change_only : job_params
    @job.assign_attributes(sel_job_params)
    # This to make this job not published to Google
    @job.is_goolge_published = false
    if params[:job][:old_organization].present? && @job.save(validate: false) && @job.add_certificates(params[:job][:certificates]) && @job.add_skills(params[:job][:skills]) && @job.send_cancellation_email_to_requisition && @job.create_requisitions
       @job.update_log_history @current_user, 'Update Organization for Job'
       render json: @job, serializer: JobAuthorizedSerializer, root: :job, ar: params[:ar]
    elsif @job.is_sent? && @job.save(validate: false) && @job.add_certificates(params[:job][:certificates]) && @job.add_skills(params[:job][:skills])
      @job.update_log_history @current_user, 'Update Content in Job'
      render json: @job, serializer: JobAuthorizedSerializer, root: :job, ar: params[:ar]
    elsif @job.save && @job.add_certificates(params[:job][:certificates]) && @job.add_skills(params[:job][:skills])
      @job.update_log_history @current_user, 'Update Content in Job'
      render json: @job, serializer: JobAuthorizedSerializer, root: :job, ar: params[:ar]
    else
      render json: @job.errors, status: :unprocessable_entity
    end
  end

  def employment_type
    if params[:employment_type].nil?
      render json: { error: 'employment_type_missing' }, status: 400 and return
    end
    if params[:employment_type] === 'internal' && @job.has_external_applications
      render json: { message: 'job_has_external_applications' }, status: 400 and return
    end
    if params[:employment_type] === 'external' && @job.has_internal_applications
      render json: { message: 'job_has_internal_applications' }, status: 400 and return
    end

    if @job.update(employment_type: params[:employment_type])
      render json: @job, serializer: JobAuthorizedSerializer, root: :job, ar: params[:ar] and return
    end

    render json: @job.errors, status: :unprocessable_entity
  end

  def export_all_candidates_requisitions
    if params[:q] && params[:q][:organization_id_in]
      organizations = Organization.where(id: params[:q][:organization_id_in])
      all_orgnaizations_ids = organizations.map{ |org| org.all_children_organizations.map(&:id) }.flatten
      params[:q][:organization_id_in] = all_orgnaizations_ids
    end
    @document = if params[:all_requisitions]
                  Job.export_all_requisitions params[:q]
                  @filename = "#{Rails.application.secrets['BACKEND']}/jobseekers-excel/#{Job.export_file_name_all_requisition}"
                elsif params[:all_applicants]
                  if params[:q] && params[:q][:organization_id_in]
                    params[:q][:job_organization_id_in] = params[:q][:organization_id_in]
                  end
                  Job.export_all_applicants_with_filter params[:q]
                  @filename = "#{Rails.application.secrets['BACKEND']}/jobseekers-excel/#{Job.export_file_name_all_applicants}"
                end
    # send_data @document.file.read, filename: @document.name
    respond_to do |format|
      format.all {
        render json: {name: @filename}
        # redirect_to @filename
      }
    end

  end

  def export_candidates
    @document = if params[:requisition_status]
                  @job.export_requisitions params[:requisition_status]
                  @filename = "#{Rails.application.secrets['BACKEND']}/jobseekers-excel/#{@job.export_file_name_requisition}"
                elsif params[:all_applicants]
                  @job.export_all_applicants
                  @filename = "#{Rails.application.secrets['BACKEND']}/jobseekers-excel/#{@job.all_applicants_file_name}"
                else
                  @job.export_candidates params[:q], params[:interview_status]
                  @filename = "#{Rails.application.secrets['BACKEND']}/jobseekers-excel/#{@job.export_file_name(params[:q][:job_application_status_id_eq])}"
                end
    # send_data @document.file.read, filename: @document.name
    respond_to do |format|
      format.all {
        render json: {name: @filename}
        # redirect_to @filename
      }
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job.update_attribute(:deleted, true)
    if !@job.job_request.blank?
      @job.job_request.update_attribute(:deleted, true)
    end
    render nothing: true, status: 204
  end

  def delete_bulk
    Job.where(id: params[:job_ids]).find_each { |m| m.update_attribute(:deleted, true) }
    render nothing: true, status: :no_content
  end

  # GET /all_jobs
  # order params are [create_at]
  def all_jobs
    params[:q] ||= {}
    params[:q][:id_in] = Job.active.internal_hiring(@current_user).pluck(:id) << -1
    @jobs = Job.calculate_matching_percentage(@current_user.jobseeker, params[:q], params[:order]).paginate(page: params[:page])
    render json: @jobs, meta: pagination_meta(@jobs), each_serializer: JobListSerializer, ar: params[:ar]
  end

  def suggested_jobs
    search_params = {}
    search_params[:id_in] = Job.active.pluck(:id) << -1
    @jobs = Job.suggested_jobs(@current_user.jobseeker, params[:order], search_params).paginate(page: params[:page])
    render json: @jobs, meta: pagination_meta(@jobs), each_serializer: JobListSerializer, ar: params[:ar]
  end

  # TODO: This one not tested till add featured jobs
  def featured_jobs
    @jobs = Job.calculate_matching_percentage(@current_user.jobseeker, params[:q], params[:order]).paginate(page: params[:page])
    render json: @jobs, each_serializer: JobListSerializer, ar: params[:ar]
  end

  # This action for employer
  # By Default order by number of Views
  def top_viewed_jobs
    @jobs = Job.active.order("views_count DESC NULLS LAST").limit(50)
    render json: @jobs, each_serializer: JobListForCompaniesSerializer, ar: params[:ar]
  end



  # Seaching Applicants Education School for this job
  def search_applicants_education_school_gp
    @jobseeker_education_ids = JobseekerEducation.where(jobseeker_id: JobApplication.where(job_id: @job.id, jobseeker_id:
        JobseekerGraduateProgram.matched_criteria.pluck(:jobseeker_id)).
        ransack(params[:q]).result.distinct(true).pluck(:jobseeker_id)).ransack(params[:q]).
        result.distinct(true).pluck(:id)

    @jobseeker_school = JobApplication.get_applications_of_job_group_by_school(@job, @jobseeker_education_ids)

    render json: @jobseeker_school.to_a
  end

  # Seaching Applicants Education Field of Study for this job
  def search_applicants_education_field_study_gp
    @jobseeker_education_ids = JobseekerEducation.where(jobseeker_id: JobApplication.where(job_id: @job.id, jobseeker_id:
        JobseekerGraduateProgram.matched_criteria.pluck(:jobseeker_id)).ransack(params[:q]).
        result.distinct(true).pluck(:jobseeker_id)).ransack(params[:q]).result.distinct(true).pluck(:id)

    @jobseeker_field_study = JobApplication.get_applications_of_job_group_by_field_of_study(@job, @jobseeker_education_ids)
    render json: @jobseeker_field_study.to_a
  end



  # Return Junk Applicants for this job. Used for Requisition
  def junk_applicants

    # All Candidates that applied
    applied_jobseeker_ids = JobApplication.where(job_id: @job.id).ransack(params[:q]).result.distinct(true).pluck(:jobseeker_id)

    # Jobseeker who match search criteria
    applied_jobseeker_ids_matching_criteria = jobseeker_selection_criteria(applied_jobseeker_ids)

    # Jobseekers that dont match criteria
    applied_jobseeker_ids = applied_jobseeker_ids - applied_jobseeker_ids_matching_criteria

    @applicants_ids = Jobseeker.where(id: applied_jobseeker_ids).ransack(params[:q]).result.pluck(:id)
    @applicants = Jobseeker.calculate_matching_percentage(@job, {id_in: (@applicants_ids << -1)}, 0, 100, params[:order]).paginate(page: params[:page])

    # send job_id to return status of job_application with each applicant record
    render json: @applicants.to_a.uniq, meta: pagination_meta(@applicants),
           each_serializer: JobseekerListSerializer, root: :applicants, job_id: @job.id, ar: params[:ar]
  end


  # Seaching Applicants Education School for this job
  def search_applicants_education_school
    @jobseeker_education_ids = JobseekerEducation.where(jobseeker_id: JobApplication.where(job_id: @job.id).
        ransack(params[:q]).result.distinct(true).pluck(:jobseeker_id)).ransack(params[:q]).
        result.distinct(true).pluck(:id)

    @jobseeker_school = JobApplication.get_applications_of_job_group_by_school(@job, @jobseeker_education_ids)

    render json: @jobseeker_school.to_a
  end

  # Seaching Applicants Education Field of Study for this job
  def search_applicants_education_field_study
    @jobseeker_education_ids = JobseekerEducation.where(jobseeker_id: JobApplication.where(job_id: @job.id).ransack(params[:q]).
        result.distinct(true).pluck(:jobseeker_id)).ransack(params[:q]).result.distinct(true).pluck(:id)

    @jobseeker_field_study = JobApplication.get_applications_of_job_group_by_field_of_study(@job, @jobseeker_education_ids)
    render json: @jobseeker_field_study.to_a
  end


  # Reutrn Applicants for this job
  # TODO: Remove this method
  def applicants_old
    params[:order] ||= "years_of_experience"
    params[:gp] ||= false
    per_page = params[:all].blank? ? (params[:per_page] || JobApplication.per_page) : JobApplication.count

     if Rails.application.secrets[:ACTIVATE_REQUISITION]
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

      # @applicants_ids_user = Jobseeker.where(user_id: User.where(email: params[:email])).pluck(:id)
      @applicants_ids_user = Jobseeker.where(user_id: User.ransack(params[:q]).result.distinct(true).pluck(:id)).pluck(:id)
      @applicants_ids = @applicants_ids & @applicants_ids_user
    end

    Jobseeker.per_page = (params[:all].present? && params[:all] == true)? 10 : Jobseeker.count()
    @applicants = Jobseeker.calculate_matching_percentage(@job, {id_in: (@applicants_ids << -1)}, 0, 100, params[:order]).paginate(page: params[:page], per_page: per_page)

    # send job_id to return status of job_application with each applicant record
    render json: @applicants.to_a.uniq, meta: pagination_meta(@applicants),
           each_serializer: JobseekerListSerializer, root: :applicants, job_id: @job.id, ar: params[:ar]
  end

  def applicants
    per_page = (params[:all].present? && params[:all] == true) ? Jobseeker.count : Jobseeker.per_page
    @q = Jobseeker.order_desc.where(id: JobApplication.where(job_id: @job.id).ransack(params[:q]).result.distinct(true).pluck(:jobseeker_id)).order(created_at: :desc).ransack(params[:q])
    @applicants = @q.result.distinct(true).paginate(page: params[:page], per_page: per_page)
    if @current_user.is_hiring_manager?
      @q = Jobseeker.order_desc.where(id: JobApplication.where(job_id: @job.id).where("shared_with_hiring_manager = ? OR user_id = ?", true, @current_user.id).ransack(params[:q]).result.distinct(true).pluck(:jobseeker_id)).ransack(params[:q])
    else
      @q = Jobseeker.order_desc.where(id: JobApplication.where(job_id: @job.id).ransack(params[:q]).result.includes(:job_application_status).distinct(true).pluck(:jobseeker_id)).ransack(params[:q])
    end


    @applicants = @q.result.paginate(page: params[:page], per_page: per_page)
    # send job_id to return status of job_application with each applicant record
    render json: @applicants, meta: pagination_meta(@applicants),
           each_serializer: JobseekerListSerializer, root: :applicants, job_id: @job.id, ar: params[:ar]
  end

  # Export All application for a job to csv
  def applicants_export_csv
    respond_to do |format|
      format.html
      format.json { send_data( @job.export_applicants_csv, :filename => "#{Date.today}_graduate_program.csv" ) }
    end
  end


  # Export Junk application for graduate program job to csv
  def applicants_export_csv_gp_junk
    respond_to do |format|
      format.html
      format.json { send_data( @job.export_applicants_csv_gp_junk, :filename => "#{Date.today}_graduate_program_junk.csv" ) }
    end
  end

  # This action get jobseekers from suggested_candidates table - Don't calculate it running time
  def suggested_jobseekers
    params[:order] ||= "years_of_experience"

    if @job.suggested_jobseekers.blank?
      @job.delay.set_suggested_candidates
    end

    @q = @job.suggested_jobseekers.select("jobseekers.*, suggested_candidates.matching_percentage").send("order_by_#{params[:order]}").ransack(params[:q])
    @jobseekers = @q.result.paginate(page: params[:page])

    render json: @jobseekers, meta: pagination_meta(@jobseekers),
           each_serializer: JobseekerListSerializer, root: :jobseekers, job_id: @job.id, ar: params[:ar]
  end

  def job_applications_analysis
    if Rails.application.secrets[:ACTIVATE_REQUISITION]
      # All Candidates that applied
      applied_jobseeker_ids = JobApplication.not_deleted.where(job_id: @job.id).pluck(:jobseeker_id)

      # Jobseeker who match search criteria
      applied_jobseeker_ids = jobseeker_selection_criteria(applied_jobseeker_ids)

      render json: @job, serializer: JobApplicationAnalysisRequisitionSerializer,
             applied_jobseeker_ids: applied_jobseeker_ids, root: :job_application_analysis
    else
      render json: @job, serializer: JobApplicationAnalysisSerializer
    end
  end

  def job_applications_analysis_gp
    render json: @job, serializer: JobApplicationAnalysisGpSerializer
  end

  # def applicant_analytics
  #   render json: @job, serializer: ApplicantAnalyticsSerializer, root: :job, ar: params[:ar], gp: params[:gp]
  # end
  #


  def applicant_analytics

    params[:gp] ||= false
    # if params[:gp]
    #   render json: @job, serializer: ApplicantAnalyticsSerializer, root: :job, ar: params[:ar], gp: params[:gp]
    # els
    if Rails.application.secrets[:ACTIVATE_REQUISITION]

      # All Candidates that applied
      applied_jobseeker_ids = JobApplication.where(job_id: @job.id).pluck(:jobseeker_id)

      # Jobseeker who match search criteria
      applied_jobseeker_ids = jobseeker_selection_criteria(applied_jobseeker_ids)

      render json: @job, serializer: ApplicantAnalyticsSerializer, root: :job, ar: params[:ar],
             applied_jobseeker_ids: applied_jobseeker_ids, gp: params[:gp]
    else
      render json: @job, serializer: ApplicantAnalyticsSerializer, root: :job, ar: params[:ar], gp: params[:gp]
    end
  end

  def get_filters_with_applicants_count_gp
    job_application_ids =  JobApplication.where(jobseeker_id: Jobseeker.ransack(params[:q]).result.pluck(:id))
        .matched_criteria_graduate_program(@job)

    render json: @job, serializer: FilterWithApplicantsCountGpSerializer, root: :filters, ar: params[:ar],
           query_params: params[:q], job_application_ids: job_application_ids
  end


  def get_filters_with_applicants_count
    if Rails.application.secrets[:ACTIVATE_REQUISITION]
      # All Candidates that applied
      applied_jobseeker_ids = JobApplication.where(job_id: @job.id).pluck(:jobseeker_id)

      # Jobseeker who match search criteria
      applied_jobseeker_ids = jobseeker_selection_criteria(applied_jobseeker_ids)

      render json: @job, serializer: FilterWithApplicantsCountRequisitionSerializer,
             applied_jobseeker_ids: applied_jobseeker_ids, root: :filters, ar: params[:ar]
    else
      render json: @job, serializer: FilterWithApplicantsCountSerializer, root: :filters, ar: params[:ar], query_params: params[:q]
    end
  end

  def close
    if @job.update(job_status_id: JobStatus.find_by(status: 'Closed').try(:id))
      @job.position.unlock_position if @job.can_unlock?
      JobHistory.create!(
        job: @job,
        job_action_type: 'closing_job',
        user: @current_user
      )
      render json: @job, serializer: JobAuthorizedSerializer, root: :job, ar: params[:ar] and return
    end

    render json: @job.errors, status: :unprocessable_entity
  end


  private

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

  # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find_by_id(params[:id])
    end


    def share_params
      params.require(:share_job).permit(:email, :share_message)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit(:title, :organization_id, :description, :qualifications, :requirements,
                                  :job_status_id, :job_type_id, :start_date, :end_date, :position_id,
                                  :city_id, :country_id, :sector_id, :functional_area_id, :department_id,
                                  :job_education_id, :job_experience_level_id, :experience_from,
                                  :experience_to, :salary_range_id, :join_date, :is_internal_hiring,
                                  :age_group_id, :gender, :marital_status, :visa_status_id, :employment_type,
                                  :notification_type, :license_required, :user_id, :active, :deleted, :branch_id, :benefit_ids => [],
                                  :geo_group_ids => [], :geo_country_ids => [], :skill_ids => [], :certificate_ids => [],
                                  :language_ids => [], job_recruiters_attributes: [:id, :user_id, :_destroy]).merge!(latest_changor_user_id: @current_user.id)

    end

    def job_params_status_change_only
      params.require(:job).permit(:job_status_id, :active, :deleted).merge!(latest_changor_user_id: @current_user.id)
    end

    def update_search_params
      set_job
      update_search_params_jobseekers
    end

    def job_owner
      if params[:id].nil? || !@current_company.jobs.pluck(:id).include?(params[:id].to_i)
        @current_ability.cannot params[:action].to_sym, Job
        authorize!(params[:action].to_sym, Job)
      end
    end

  def check_permissions_update
    # Validation if only permission to update job
    update_own_only = (@current_user.permissions.update_own_job.count > 0)
    update_other_only = (@current_user.permissions.update_other_job.count > 0)
    if update_own_only || update_other_only
      can_update_own = false
      can_update_other = false

      # Validating update own
      if update_own_only && @job.user.id == @current_user.id
        can_update_own = true
      end

      # Validating update others
      if update_other_only && @job.user.id != @current_user.id
        can_update_other = true
      end

      if !can_update_own && !can_update_other
        reject_action
      end
    end
  end

  def check_permissions_destroy
    # Validation if only permission to update job
    destroy_own_only = (@current_user.permissions.destroy_own_job.count > 0)
    destroy_other_only = (@current_user.permissions.destroy_other_job.count > 0)
    if destroy_own_only || destroy_other_only
      can_destroy_own = false
      can_destroy_other = false

      # Validating update own
      if destroy_own_only && @job.user.id == @current_user.id
        can_destroy_own = true
      end

      # Validating update others
      if destroy_other_only && @job.user.id != @current_user.id
        can_destroy_other = true
      end

      if !can_destroy_own && !can_destroy_other
        reject_action
      end
    end
  end


  def reject_action
    @current_ability.cannot params[:action].to_sym, Job
    authorize!(params[:action].to_sym, Job)
  end

end
