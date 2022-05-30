class Api::V1::CompaniesController < ApplicationController
  skip_before_action :authenticate_user, only: [:index, :show, :jobs, :show_analytics]
  before_action :set_jobseeker, only: [:follow, :unfollow]
  before_action :set_company, only: [:show, :show_details, :follow,
                                     :unfollow, :jobs, :blogs, :update, :followers, :jobs_graph,
                                     :job_applications_percentage, :users, :followers_percentage,
                                     :upload_avatar, :upload_cover, :upload_management_video]

  before_action :company_owner, only: [:update, :followers, :jobs_graph, :job_applications_percentage,
                                       :followers_percentage, :upload_avatar, :upload_cover, :upload_management_video]

  # This is called if send wrong params to get companies in order
  # rescue_from NoMethodError, with: :render_exception_error

  # GET /companies
  # GET /companies.json
  def index
    per_page = params[:all] ? Company.count : Company.per_page
    params[:order] ||= "alphabetical"

    @q = Company.active.send("order_by_#{params[:order]}").ransack(params[:q])
    @companies = @q.result.paginate(page: params[:page], per_page: per_page)
    if params[:all]
      render json: @companies, meta: pagination_meta(@companies), each_serializer: CompanyAllSerializer, ar: params[:ar]
    else
      render json: @companies, meta: pagination_meta(@companies), each_serializer: CompanyListSerializer, ar: params[:ar]
    end
  end

  # To display public details for company
  def show
    render json: @company, serializer: CompanySerializer, root: :company, ar: params[:ar]
  end

  # To display authorized details for company
  def show_details
    render json: @company, serializer: CompanyAuthorizedSerializer, root: :company, ar: params[:ar]
  end

  # To display authorized analytics for company
  def show_analytics
    render json: @company, serializer: CompanyAnalyticsSerializer, root: :company_analytics, ar: params[:ar]
  end

  def follow
    company_follower = @company.company_followers.new(jobseeker_id: @jobseeker.try(:id))

    if company_follower.save
      render json: @company, serializer: FollowCompanySerializer, root: :company, ar: params[:ar]
    else
      render json: company_follower.errors, status: :unprocessable_entity
    end
  end

  def unfollow
    @company_follower = @company.company_followers.find_by(jobseeker_id: @jobseeker.try(:id))
    @company_follower.destroy unless @company_follower.nil?
    render json: @company, serializer: FollowCompanySerializer, root: :company, ar: params[:ar]
  end

  # nested jobs of company & this action for jobseeker & employer
  def jobs_old
    per_page = params[:all] ? @company.jobs.count : Job.per_page
    params[:show_all] ||= false
    if Rails.application.secrets[:ACTIVATE_REQUISITION] && !params[:show_all]
      job_ids = JobRequest.ransack(params[:q]).result.pluck(:job_id)
      old_job_ids = @company.jobs.ransack(params[:q]).result.pluck(:id)
      job_ids = job_ids &&  old_job_ids
      @q = @current_user.nil? || @current_user.is_jobseeker? ? @company.jobs.order(created_at: :desc).active.ransack(params[:q]) :
               @company.jobs.order(created_at: :desc).where(id: job_ids).ransack(params[:q])
    else
      #@ToDo: For graduate program a fix is required here. Currently cant get details for graduate program job
      @q = @current_user.nil? || @current_user.is_jobseeker? ? @company.jobs.order(created_at: :desc).active.ransack(params[:q]) : @company.jobs.order(created_at: :desc).ransack(params[:q])
    end

    @jobs = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @jobs, meta: pagination_meta(@jobs), each_serializer: CompanyJobSerializer, root: :jobs, ar: params[:ar]
  end

  def jobs_current_user
    per_page = params[:all] ? @company.jobs.count : Job.per_page
    @q = @current_user.jobs.order(created_at: :desc).ransack(params[:q])
    @jobs = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @jobs, meta: pagination_meta(@jobs), each_serializer: CompanyJobSerializer, root: :jobs, ar: params[:ar]
  end

  def jobs
    per_page = params[:all] ? @company.jobs.count : Job.per_page

    # @q = @current_user.jobs.ransack(params[:q])
    # @q = Job.where(organization_id: @current_user.all_organization_ids).order(created_at: :desc).ransack(params[:q])

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

    job_ids = @current_user.accessable_job_ids

    @q = if job_ids.blank?
           Job.order(approved_at: :desc).ransack(params[:q])
         else
           Job.order(approved_at: :desc).where(id: job_ids).ransack(params[:q])
         end

    @jobs = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @jobs, meta: pagination_meta(@jobs), each_serializer: params[:mini]? CompanyJobMiniSerializer : CompanyJobSerializer, root: :jobs, ar: params[:ar]
  end

  def jobs_for_interview

    per_page = params[:all] ? @company.jobs.count : Job.per_page

    @q = Job.where(id: JobApplication.interviewed.pluck(:job_id)).where(id: InterviewCommitteeMember.where(user_id: @current_user.id).map{|i| i.interview.job.id}).order(created_at: :desc).ransack(params[:q])
    @jobs = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @jobs, meta: pagination_meta(@jobs), each_serializer: CompanyJobSerializer, root: :jobs, ar: params[:ar]
  end

  def received_jobs
    per_page = params[:all] ? @company.jobs.count : Job.per_page
    @q = Job.where(id: Requisition.active.where(user_id: @current_user.id).map(&:job_id) << -1).order(created_at: :desc).ransack(params[:q])
    @jobs = @q.result.paginate(page: params[:page], per_page: per_page)
    render json: @jobs, meta: pagination_meta(@jobs), each_serializer: CompanyJobSerializer, root: :jobs, ar: params[:ar]
  end

  def blogs
    @q = @current_user.is_jobseeker? ? @company.blogs.active.order(created_at: :desc).ransack(params[:q]) : @company.blogs.order(created_at: :desc).ransack(params[:q])
    @blogs = @q.result.paginate(page: params[:page])
    render json: @blogs, meta: pagination_meta(@blogs), each_serializer: BlogListSerializer, root: :blogs
  end

  def users
    per_page = params[:all] ? @company.users.existing.count : User.per_page
    @users = @company.users.existing.ransack(params[:q]).result.paginate(page: params[:page], per_page: per_page)
    render json: @users, meta: pagination_meta(@users), each_serializer: CompanyUserSerializer,
           root: :users, company_id: @company.id, ar: params[:ar]
  end

  def update
    if @company.update(company_params)
      render json: @company, serializer: CompanySerializer, root: :company, ar: params[:ar]
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  def followers
    @q = @company.followers.ransack(params[:q])
    @jobseekers = @q.result.paginate(page: params[:page])
    render json: @jobseekers, meta: pagination_meta(@jobseekers), each_serializer: FollowersSerializer, root: :followers, ar: params[:ar]
  end

  # TODO: Remove sending params[:q] to Serializer & Find Another Solution - Now Quick Solution
  def jobs_graph
    render json: @company, serializer: JobsGraphSerializer, root: :jobs_graph, ar: params[:ar], q: params[:q]
  end

  # TODO: Remove sending params[:q] to Serializer & Find Another Solution - Now Quick Solution
  def job_applicants_graph
    render json: @company, serializer: JobApplicantsGraphSerializer, root: :job_applicants_graph, ar: params[:ar], q: params[:q]
  end

  # TODO: Remove sending params[:q] to Serializer & Find Another Solution - Now Quick Solution
  def job_applications_percentage
    render json: @company, serializer: CompanyJobApplicationsGroupedSerializer, root: :job_applications, ar: params[:ar], q: params[:q]
  end

  def followers_percentage
    render json: @company, serializer: CompanyFollowersGraphSerializer, root: :followers, ar: params[:ar]
  end

  # Upload Avatar
  def upload_avatar
    if @company.upload_avatar(params[:company][:avatar])
      render json: @company, serializer: CompanySerializer, root: :company, ar: params[:ar]
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  #Upload Cover
  def upload_cover
    if @company.upload_cover(params[:company][:cover])
      render json: @company, serializer: CompanySerializer, root: :company, ar: params[:ar]
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  #Upload Management Video
  def upload_management_video
    if @company.upload_management_video(params[:company][:management_video])
      @company.owner_name = params[:company][:owner_name]
      @company.owner_designation = params[:company][:owner_designation]
      render json: @company, serializer: CompanySerializer, root: :company, ar: params[:ar]
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end


  def delete_management_video
    @company.video_our_management = nil
    if @company.save
      render json: @company, serializer: CompanySerializer, root: :company, ar: params[:ar]
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end


  def delete_avatar
    @company.avatar = nil
    if @company.save
      render json: @company, serializer: CompanySerializer, root: :company, ar: params[:ar]
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  def delete_cover
    @company.cover = nil
    if @company.save
      render json: @company, serializer: CompanySerializer, root: :company, ar: params[:ar]
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  private
    def set_company
      @company = Company.active.find_by_id(params[:id])
      raise ActiveRecord::RecordNotFound if @company.nil?
    end

    def set_jobseeker
      @jobseeker = @current_user.jobseeker
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name, :summary, :website, :current_city_id, :current_country_id, :address_line1,
                                      :address_line2, :phone, :fax, :contact_email, :po_box, :contact_person,
                                      :google_plus_page_url, :linkedin_page_url, :facebook_page_url, :twitter_page_url,
                                      :active, :sector_id, :company_size_id, :company_type_id, :owner_designation,
                                      :owner_name, :company_classification_id, :latitude, :longitude, :avatar, :cover,
                                      :city_id, :country_id, :establishment_date, :total_male_employees, :total_female_employees)
    end

    def company_owner
      if @current_user.is_employer? && (params[:id].nil? || !@current_user.company_ids.include?(params[:id].to_i))
        @current_ability.cannot params[:action].to_sym, Company
        authorize!(params[:action].to_sym, Company)
      end
    end

end
