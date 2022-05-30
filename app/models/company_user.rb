class CompanyUser < ActiveRecord::Base
  include SendInvitation
  include Pagination

  belongs_to :user

  belongs_to :company
  has_many :blogs, dependent: :destroy
  has_many :notes, dependent: :destroy

  validates_presence_of :user, :company
  has_many :jobseeker_profile_views, foreign_key: :company_user_id, dependent: :destroy


  has_attached_file :document_e_signature, dependent: :destroy

  validates_attachment_content_type :document_e_signature, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp"]
  # after_create :send_notification_to_new_user

  # the following hash contain permission_key that's used by frontend &
  # permission_val that is array of objects, each object has controller_name as key & the value is array of actions
  
  UploadDocument = Struct.new(:company_user, :document_local_path) do
    def perform
      company_user.document_e_signature = File.open(document_local_path)
      company_user.save
    end
  end
  PERMISSIONS_OLD = {
      edit_company: [
          {"Company" => ["update", "upload_avatar", "upload_cover"]},
          {"CompanyMember" => ["create", "update", "destroy", "upload_avatar"]},
          {"Culture" => ["create", "update", "destroy", "upload_avatar"]}
      ],
      invite_connection: [
          {"UserInvitation" => ["invite", "get_contacts", "failure", "get_twitter_friends",
                                "invite_by_twitter", "invite_by_email"]}
      ],
      manage_users: [
          {"User" => ["create", "update", "destroy"]},
          {"CompanyUser" => ["create", "update", "destroy"]}
      ],
      create_job: [
          {"Job" => ["create"]},
          {"JobRequest" => ["create"]}
      ],
      update_job: [
          {"Job" => ["update"]},
          {"JobRequest" => ["update", "request_approval", "update_approvers", "destroy", "delete_bulk"]}
      ],
      view_all_job: [
          {"Job" => ["index", "show"]}
      ],
      activate_deactivate_job: [
          {"Job" => ["none"]}
      ],
      update_other_job: [
          {"Job" => ["none"]}
      ],
      destroy_other_job: [
          {"Job" => ["none"]}
      ],
      update_own_job: [
          {"Job" => ["none"]}
      ],
      destroy_own_job: [
          {"Job" => ["none"]}
      ],
      edit_job_application_status: [
          {"JobApplicationStatusChange" => ["create", "create_bulk", "create_bulk_status_change", "create_bulk_status_change_on_search_criteria"]}
      ],
      interview_only: [
          {"JobApplicationStatusChange" => ["none"]}
      ],
      shortlist_only: [
          {"JobApplicationStatusChange" => ["none"]}
      ],
      offer_only: [
          {"JobApplicationStatusChange" => ["none"]}
      ],
      destroy_job: [
          {"Job" => ["destroy"]}
      ],
      search_jobseekers: [
          {"Jobseeker" => ["index"]}
      ],
      share_jobseekers: [
          {"Jobseeker" => ["share"]}
      ],
      create_jobseekers: [
          {"Jobseeker" => ["create"]}
      ],
      create_blog: [
          {"Blog" => ["create"]}
      ],
      manage_blog: [
          {"Blog" => ["update", "destroy", "upload_avatar", "delete_avatar", "upload_video", "delete_video"]}
      ],
      dashboard: [
          {"Company" => ["none"]}
      ],
      user_access: [
          {"Company" => ["none"]}
      ],
      admin_values: [
          {"HiringManager" => ["none"]}
      ],
      folders: [
          {"JobseekerFolder" => ["none"]}
      ],
      graduate_program: [
          {"JobseekerGraduateProgram" => ["none"]}
      ],
      candidate_search: [
          {"Jobseeker" => ["index"]}
      ],
      evaluation_form: [
          {"EvaluationForm" => ["create", "update", "index"]},
          {"EvaluationQuestion" => ["create", "update", "index"]},
          {"EvaluationAnswer" => ["create", "update", "index"]}
      ]
  }

  PERMISSIONS = {
      # evaluation_form: [
      #     {"EvaluationForm" => ["create", "update", "index"]},
      #     {"EvaluationQuestion" => ["create", "update", "index"]},
      #     {"EvaluationAnswer" => ["create", "update", "index"]}
      # ],
      # candidate_search: [
      #     {"Jobseeker" => ["index"]}
      # ],
      # create_jobseekers: [
      #     {"Jobseeker" => ["create"]}
      # ],
      # share_jobseekers: [
      #     {"SharedJobseeker" => ["create"]}
      # ],
      # create_job: [
      #     {"Job" => ["create", "update"]},
      #     {"JobRequest" => ["create", "update", "request_approval", "update_approvers", "destroy", "delete_bulk"]}
      # ],
      # schedule_interviews: [
      #     {"JobApplicationStatusChange" => ["create", "create_bulk", "create_offer_letter"]},
      #     {"Interview" => ["create", "update"]}
      # ],
      admin_values: [
          # {"CompanyUser" => ["create", "update"]},
          {"Organization" => ["create", "update"]},
          {"Position" => ["create", "update", "destroy"]},
          {"Grade" => ["create", "update", "destroy"]}
      ]
  }

  def send_notification_to_new_user(password='Test@1234')
     raw, enc = Devise.token_generator.generate(self.user.class, :reset_password_token)
    self.user.reset_password_token   = enc
    self.user.reset_password_sent_at = Time.now.utc
    self.user.save(validate: false)
    templates_values = {
        CreatedDate: self.created_at.strftime("%d %b, %Y"),
        Subject: "NEW USER CREATED FOR YOU",
        CreatedName: self.user.full_name,
        CreatorName: self.company.owner.first_name,
        CompanyName: self.company.name,
        CompanyImg: self.company.avatar(:original),
        CreateDate: self.created_at.strftime("%d %b, %Y"),
        CreatedEmail: self.user.email,
        CreatedPassword: password,
        RestPasswordUrl: "#{Rails.application.secrets[:FRONTEND]}/change-password?reset_password_token=#{raw}&email=#{self.user.email}",
        MainLogo: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
        primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
        secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
        lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
        borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
        WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"],
        OrgName: self.user.organizations.first.try(:name) || "N/A"
    }

    self.send_email "new_user",
                    [{email: self.user.email, name: self.user.full_name}],
                    {message_body: nil, template_values: templates_values}
  end

  class << self
    # user_params = {first_name: "", last_name: "", role: "", email: ""}
    # permissions: ["edit_company", "invite_connection", "create_job", "edit_job_application_status",
    #               "destroy_job", "search_jobseekers", "create_blog", "manage_blog"]
    def create_company_user user_params, company, permissions
      # TODO: Put Random Password
      user_params[:password] ||= "Test@1234"
      user_params[:password_confirmation] ||= user_params[:password]
      user_params[:active] ||= false
      user_params[:deleted] ||= false
      #user_params[:birthday] ||= company.company_owner.birthday

      # find_by email first to redo the soft delete
      user = User.new(edit_user_params(user_params))
      # Company users are already confirmed on creation. Only reset password email will be sent
      user.skip_confirmation!
      user.skip_confirmation_notification!

      user.confirmed_at = DateTime.now

      user.save

      # TODO: Refactor this part after used nested attributes in create & update
      user.update_attribute(:role, "company_admin") if user.is_company_owner?
      company_user = CompanyUser.find_or_create_by(user_id: user.id, company_id: company.id) if user.present? && user.valid?
      # ToDo: Check with Yakout 
      #company_user.send_notification_to_user(user_params[:password])

      if user.nil? || company_user.nil? || !user.valid? || !company_user.valid?
        return user
      end

      append_permissions user, permissions

      user
    end

    # This method to update permissions with new permissions & delete the previous
    # TODO: Change the auth_token after update, to force this user re-login with the new auth_token
    def update_company_user user, permissions
      return user if permissions.nil?

      append_permissions user, permissions

      deleted_permission_names = user.permissions_names - permissions
      user.permissions.where(name: deleted_permission_names).destroy_all
      user
    end

    # return ActionController::Parameters
    def edit_user_params params
      params.permit(:email, :first_name, :last_name, :position, :role_id, :password, :password_confirmation, :active, :deleted, :birthday,
                    :section_id , :new_section_id, :department_id, :office_id, :unit_id, :grade_id, :is_recruiter, :is_interviewer, :oracle_id, 
                    :ext_employer_id, :start_date, :end_date, :document_e_signature, :is_last_approver, :is_approver, organization_ids: [])
    end

    # This method to append the permissions to user without duplicate
    def append_permissions user, permissions
      permissions.each do |permission_key|
        controllers_actions = CompanyUser::PERMISSIONS[permission_key.to_sym]
        if controllers_actions.present?
          controllers_actions.each do |cancan_obj|
            cancan_obj.each do |controller_name, actions|
              actions.each{|action| Permission.find_or_create_by(user_id: user.id, controller_name: controller_name, action: action, name: permission_key)}
            end
          end
        end
      end
    end

  end
end
