class Api::V1::CompanyUsersController < ApplicationController
  before_action :set_company_user, except: [:create]
  # before_action :company_owner, only: [:employer_details]
  before_action :update_my_account, only: [:active, :inactive, :destroy]

  # Return users in company for company_user
  def users
    per_page = params[:all].blank? ? (params[:per_page] || User.per_page) : User.active.count
    @q = @company_user.company.users.existing.order_by_desc.ransack(params[:q])
    @users = @q.result(distinct: true).paginate(page: params[:page], per_page: per_page)
    render json: @users, meta: pagination_meta(@users), each_serializer: CompanyUserSerializer, root: :users, company_id: @current_company.id
  end

  # Return jobs created by company_user
  def jobs
    # TODO: Migration to remove company_id & user_id from Jobs table & Add company_user_id
    @jobs = Job.where(company_id: @company_user.company_id, user_id: @company_user.user_id).paginate(page: params[:page])
    render json: @jobs, meta: pagination_meta(@jobs), each_serializer: JobListSerializer, root: :jobs, ar: params[:ar]
  end

  # Return blogs created by company_user
  def blogs
    @blogs = @company_user.blogs.order(created_at: :desc).paginate(page: params[:page])
    render json: @blogs, meta: pagination_meta(@blogs), each_serializer: BlogListSerializer, root: :blogs
  end

  # This action to get details of user with associated permissions
  # For company_owner & company_admin
  def show
    render json: @company_user.user, serializer: CompanyUserDetailsSerializer, root: :user, company_id: @current_company.id
  end

  # To get my details
  def employer_details
    render json: @current_user, serializer: CompanyUserDetailsSerializer, root: :user, company_id: @current_company.id
  end

  # This action for employer company_owner & company_admin has permission
  # {user: {email: "", first_name: "", last_name: "", role: "", active: false},
  # permissions: ["edit_company", "invite_connection", "create_job", "edit_job_application_status",
  #               "destroy_job", "search_jobseekers", "create_blog", "edit_blog", "destroy_blog"]}
  def create
    @user = CompanyUser.create_company_user params[:user], @current_company, params[:permissions]
    if @user.present? && @user.valid?

      ## Assign user to organization if present
      if params[:organization_ids].present? && !params[:organization_ids].nil?
        organization_ids = params[:organization_ids]
        organization_ids.each do |org_id|
          OrganizationUser.create(user_id: @user.id, organization_id: org_id)
        end
      end

      @user.company_users.first.send_notification_to_new_user(params[:user][:password])
      sleep 0.5
      render json: @user, serializer: CompanyUserDetailsSerializer, root: :user, company_id: @current_company.id
    elsif @user.present?
      sleep 0.5
      render json: @user.errors, status: :unprocessable_entity
    else
      sleep 0.5
      render json: {user: {errors: ["Wrong Params"]}}, status: :unprocessable_entity
    end
  end

  # push by oracle
  def push
    params[:user][:role_id] ||= Role.find_by_name(params[:user][:role][:name]).try(:id) if params[:user][:role].present?
    @user = User.find_by(oracle_id: params[:user][:oracle_id])
    if @user.present?
      @company_user = @user.company_users.first
      update
    else
      create
    end
  end

  # Update user of this company_user
  # this action only for company_owner
  # Note: This action not used for change active/inactive
  def update
    @user = @company_user.user
    @company_user.document_e_signature = params[:user][:document_e_signature] if params[:user][:document_e_signature].present?
    # TODO: Refactor this part after add validates to company limit one owner for each company
    if params[:user].present? &&
        ((@user.is_company_owner? && (params[:user][:role].present? || params[:user][:active].present?)) ||
            (params[:user][:role_id] == Role.find_by_name(Role::SUPER_ADMIN).try(:id)))
      params[:user].delete(:role_id)
      params[:user].delete(:active)
    end

    if @company_user.save! && @user.update(user_params)


      # Update user organization if hiring manager
      if @user.is_hiring_manager? && params[:organization_id].present?
        organization_user = OrganizationUser.where(user_id: @user.id).first
        organization_user.organization_id = params[:organization_id]
        organization_user.save
      end

      @user = CompanyUser.update_company_user @user, params[:permissions]
      # TODO: I put this line to reload the user with new permissions in DB (May another solution ?)
      @user.reload
      sleep 0.5
      render json: @user, serializer: CompanyUserDetailsSerializer, root: :user, company_id: @current_company.id
    else
      sleep 0.5
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # This action to inactive user
  def inactive
    @user = @company_user.user
    if @user.update(active: false)
      render json: @user, serializer: CompanyUserDetailsSerializer, root: :user, company_id: @current_company.id
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # This action to active user
  def active
    @user = @company_user.user
    # change user to active but not confirm & send the confirmation
    if @user.update(active: true, confirmed_at: nil)
      # @user.send_reset_password_instructions if @user.last_sign_in_at.nil?
      @user.send_reconfirmation_instructions if @user.last_sign_in_at.nil?
      render json: @user, serializer: CompanyUserDetailsSerializer, root: :user, company_id: @current_company.id
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # This action for company_owner & soft-delete
  def destroy
    @user = @company_user.user
    if @current_user.can_delete @user
      @user.deactivate_employer
      if @user.destroy
        @users = @current_company.users.existing.paginate(page: params[:page])
        render json: @users, meta: pagination_meta(@users), each_serializer: CompanyUserSerializer, root: :users, company_id: @current_company.id
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    else
      @current_user.errors.add(:base, "#{@current_user.email} can't delete #{@user.email}")
      render json: @current_user.errors, status: :unprocessable_entity
    end
  end

  private
    def set_company_user
      @company_user = CompanyUser.find_by_id(params[:employer_id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :middle_name, :position, :role_id, :active, :password, :password_confirmation,
                                   :section_id, :new_section_id, :department_id, :office_id, :unit_id, :grade_id, :is_recruiter, :is_interviewer,
                                   :ext_employer_id, :start_date, :end_date, :document_e_signature, :is_approver, :is_last_approver,
                                   :oracle_id, organization_ids: [])
    end

    def company_owner
      if @current_user.is_employer? && (params[:employer_id].nil? ||
          !@current_user.company_user_ids.include?(params[:employer_id].to_i))
         @current_ability.cannot params[:action].to_sym, CompanyUser
         authorize!(params[:action].to_sym, CompanyUser)
       end
    end

    def update_my_account
      set_company_user
      if @company_user.user.id == @current_user.id
        @current_ability.cannot params[:action].to_sym, CompanyUser
        authorize!(params[:action].to_sym, CompanyUser)
      end
    end
end
