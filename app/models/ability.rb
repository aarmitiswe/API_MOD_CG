class Ability
  include CanCan::Ability

  # This for any user in the system
  AUTHORIZED_USER_PERMISSION = {
      "Comment" => [
          :create, :destroy
      ],
      "Blog" => [
          :like, :dislike
      ],
      "PollQuestion" => [
          :index, :vote
      ],
      "Job" => [
          :show_details, :analysis, :show_details_pdf
      ],
      "Company" => [
          :show_details
      ],
      "User" => [
          :update, :activate, :deactivate, :get_notification, :update_notification, :delete_avatar
      ],
      "Jobseeker" => [
          :create_json_file, :display_profile, :display_profile_pdf ,:success_probability ,:update_profile_status
      ],
      "CybersourcePayment" => [
          :create
      ],
      "JobseekerRequiredDocument" => [ #TODO: Authorize action later
          :index, :show, :create, :update, :destroy, :create_bulk, :update_bulk
      ],
      "OfferLetterRequest" => [
          :index, :show, :create, :update, :destroy
      ],
      "JobApplication" => [
          :index, :show, :create, :create_bulk, :create_salary_offer_analysis, :share_hiring_managers,
          :init_security_clearance, :security_clearance_result, :generate_hiring_contract, :update_extra_document,
          :all_documents, :scan_medical_insurance, :download_history
      ],
      "SharedJobseeker" => [
          :index, :create, :update, :destroy
      ],
      "Organization" => [:index, :create, :update, :destroy, :show, :positions, :jobs, :children_organizations,
                         :upload_organizations, :current_user_organizations, :push, :remove],
      "OrganizationType" => [:index],
      "OrganizationUser" => [:index, :create, :update, :destroy, :show, :push, :remove],
      "Requisition" => [:index, :create, :update, :destroy, :show, :received, :sent],
      "Position" => [:index, :create, :update, :show, :destroy, :organization, :push, :remove],
      "EmployerNotification" => [:index, :create, :update, :show, :destroy]
  }

  # Authorized controllers && actions for each type of user
  JOBSEEKER_PERMISSION = {
      "User" => [
          :upload_profile_image, :upload_video, :delete_video
      ],
      "Jobseeker" => [
          :update, :dashboard_summary,
          :profile_views_graph, :job_applications_graph, :followed_companies_graph,
          :job_applications_by_country, :job_applications_by_sector, :profile_views,
          :update_skills, :update_tags, :completion_percentage
      ],
      "JobseekerEducation" => [
          :index, :show, :create, :update, :destroy, :delete_document, :upload_document
      ],
      "JobseekerExperience" => [
          :index, :show, :create, :update, :destroy, :delete_document, :upload_document
      ],
      "JobseekerCertificate" => [
          :index, :show, :create, :update, :destroy, :delete_document, :upload_document
      ],
      "JobseekerResume" => [
          :index, :show, :create, :update, :destroy, :delete_document, :delete_bulk
      ],
      "JobseekerCoverletter" => [
          :index, :show, :create, :update, :destroy, :delete_document, :delete_bulk
      ],
      "UserInvitation" => [
          :invite_by_email, :invite_by_twitter
      ],
      "Job" => [
          :all_jobs, :suggested_jobs, :featured_jobs, :similar_companies, :similar_jobs, :similar_careers, :export_candidates
      ],
      "SavedJob" => [
          :index, :create, :destroy, :delete_bulk
      ],
      "SavedJobSearch" => [
          :index, :create, :update, :destroy, :delete_bulk
      ],
      "Company" => [
          :follow, :unfollow
      ],
      "Interview" => [
          :index, :show, :update, :generate_token, :create_bulk, :job_application, :confirm, :update_interview_committee
      ],
      "PackageBroadcast" => [
          :index, :show
      ],
      "JobseekerPackageBroadcast" => [
         :index
      ],
      "JobseekerCompanyBroadcast" => [
          :index, :create, :create_bulk
      ],
      "CareerFairApplication" => [:index, :create]
  }
  COMPANY_OWNER_PERMISSION = {
      "PollQuestion" => [
          :create, :update
      ],
      "BudgetedVacancy" => [:create, :update, :destroy],
      "CompanyUser" => [:update, :destroy],
      "Position" => [:index, :create, :update, :show, :destroy, :organization]
  }
  COMPANY_ADMIN_PERMISSION = {
      "CompanyUser" => [:create, :show, :active, :inactive, :push]
  }
  COMPANY_USER_PERMISSION = {
      "JobApplicationStatusChange" => [
          :index, :create, :create_bulk, :create_bulk_status_change, :create_bulk_status_change_on_search_criteria,
          :create_offer_letter, :get_interviews, :update, :download_history
      ],
      "Company" => [
          :update, :followers, :jobs_graph, :job_applicants_graph, :job_applications_percentage, :followers_percentage,
          :upload_avatar, :upload_cover, :upload_management_video, :users, :blogs ,:delete_cover ,:delete_avatar,
          :delete_management_video
      ],
      "Branch" => [
          :index
      ],
      "Jobseeker" => [
          :index, :job_applications_history, :matched_with_graduate_program,
          :not_matched_with_graduate_program, :update_terminate_status
      ],
      "User" =>[
        :destroy
      ],
      "UserInvitation" => [
          :invite_by_email, :invite_by_twitter
      ],
      "Blog" => [
          :create, :update, :destroy, :upload_video, :upload_avatar, :delete_video, :delete_avatar
      ],
      "Comment" => [
          :change_status
      ],
      "Culture" => [
          :create, :update, :destroy, :upload_avatar
      ],
      "CompanyMember" => [
          :create, :update, :destroy, :upload_avatar, :delete_avatar, :delete_video
      ],
      "CompanyUser" => [
          :users, :jobs, :blogs, :employer_details
      ],
      "Job" => [
          :top_viewed_jobs, :create, :update, :destroy, :applicants, :job_applications_analysis, :junk_applicants,
          :applicant_analytics, :suggested_jobseekers, :get_filters_with_applicants_count, :share_url, :delete_bulk,
          :search_applicants_education_school, :search_applicants_education_field_study,:get_application_stage_count,
          :job_applications_analysis_gp, :get_filters_with_applicants_count_gp, :applicants_export_csv,
          :applicants_export_csv_gp_junk, :my_jobs, :export_all_candidates_requisitions, :employment_type, :close
      ],
      "Note" => [
          :index, :create
      ],
      "InvitedJobseeker" => [
          :create
      ],
      "OfferLetter" => [
          :generate, :generate_stc_contract
      ],
      "Package" => [
          :show, :index
      ],
      "Interview" => [
          :index, :show, :generate_token, :create_bulk, :job_application, :confirm
      ],
      "Folder" => [
          :index, :show, :create, :update, :destroy, :jobseekers, :sub_folders, :jobseeker_folders, :all_jobseekers
      ],
      "JobseekerFolder" => [
          :index, :show, :create, :update, :destroy
      ],
      "Rating" => [
          :index, :show, :create, :update, :destroy
      ],
      "JobseekerHashTag" => [
          :create, :create_bulk
      ],
      "HashTag" => [
          :index
      ],
      "Unit" => [
          :index, :show, :create, :update, :destroy
      ],
      "NewSection" => [
          :index, :show, :create, :update, :destroy
      ],
      "Department" => [
          :index, :show, :create, :update, :destroy
      ],
      "BudgetedVacancy" => [
          :index, :show, :count_used_budgeted_vacancies
      ],
      "Section" => [
          :index, :show, :create, :update, :destroy
      ],
      "Office" => [
          :index, :show, :create, :update, :destroy
      ],
      "Grade" => [
          :index, :show, :create, :update, :destroy
      ],
      "HiringManager" => [
          :index, :show, :create, :update, :destroy
      ],
      "JobRequest" => [
          :index, :show, :create, :update, :destroy, :delete_bulk, :update_approvers, :request_approval
      ],
      "CareerFair" => [
          :create, :update, :destroy, :applicants
      ],
      "CareerFairApplication" => [
          :index, :show, :update, :destroy
      ],
      "JobApplication" => [
          :approve_all_evaluation_submits, :update_terminate_status, :destroy
      ],
      "EvaluationForm" => [
          :index, :create, :update, :destroy, :show, :show_pdf
      ],
      "EvaluationSubmit" => [
          :index, :create, :update, :destroy
      ],
      "EvaluationSubmitRequisition" => [
          :update
      ],
      "EvaluationAnswer" => [
          :index, :create, :update, :destroy],
      "CandidateInformationDocument" => [
          :update_status, :save_as_pdf
      ],
      "Assessment" => [:update],
      "SalaryAnalysis" => [
          :index, :create, :update, :destroy
      ],
      "OfferAnalysis" => [
          :index, :create, :update, :destroy
      ],
      "OfferRequisition" => [
          :index, :create, :update, :destroy
      ],
      "BankAccount"  => [
          :index, :create, :update, :destroy, :get_file_data
      ],
      "MedicalInsurance" => [
          :index, :create, :update, :destroy, :get_file_data
      ],
      "JobseekerOnBoardDocument"=> [
          :index, :create, :update, :destroy
      ],
      "BoardingForm"=> [
          :index, :create, :update, :destroy, :generate_pdf
      ],
      "BoardingRequisition"=> [
          :index, :create, :update, :destroy
      ],
      "JobApplicationLog"=> [
          :index
      ],
      "JobHistory"=> [
          :index
      ],
      "JobseekerResume"=> [
          :application
      ]
  }

  RECRUITER_PERMISSION = {
      "JobApplicationStatusChange" => [
          :index, :create, :create_bulk, :create_bulk_status_change, :create_bulk_status_change_on_search_criteria
      ],
    #   "Company" => [
    #       :update, :followers, :jobs_graph, :job_applicants_graph, :job_applications_percentage, :followers_percentage,
    #       :upload_avatar, :upload_cover, :upload_management_video, :users, :blogs ,:delete_cover ,:delete_avatar,
    #       :delete_management_video
    #   ],
      "Branch" => [
          :index
      ],
      "Jobseeker" => [
          :index, :job_applications_history, :matched_with_graduate_program, :not_matched_with_graduate_program
      ],
      "UserInvitation" => [
          :invite_by_email, :invite_by_twitter
      ],
      "Blog" => [
          :create, :update, :destroy, :upload_video, :upload_avatar, :delete_video, :delete_avatar
      ],
      "Comment" => [
          :change_status
      ],
      "Culture" => [
          :create, :update, :destroy, :upload_avatar
      ],
    #   "CompanyMember" => [
    #       :create, :update, :destroy, :upload_avatar, :delete_avatar, :delete_video
    #   ],
    #   "CompanyUser" => [
    #       :users, :jobs, :blogs, :employer_details
    #   ],
    #   "Job" => [
    #       :top_viewed_jobs, :create, :update, :destroy, :applicants, :job_applications_analysis, :junk_applicants,
    #       :applicant_analytics, :suggested_jobseekers, :get_filters_with_applicants_count, :share_url, :delete_bulk,
    #       :search_applicants_education_school, :search_applicants_education_field_study,
    #       :job_applications_analysis_gp, :get_filters_with_applicants_count_gp, :applicants_export_csv,
    #       :applicants_export_csv_gp_junk
    #   ],
      "Job" => [
          :top_viewed_jobs, :applicants, :job_applications_analysis, :junk_applicants,
          :applicant_analytics, :suggested_jobseekers, :get_filters_with_applicants_count, :share_url,
          :search_applicants_education_school, :search_applicants_education_field_study,
          :job_applications_analysis_gp, :get_filters_with_applicants_count_gp, :applicants_export_csv,
          :applicants_export_csv_gp_junk
      ],
      "Note" => [
          :index, :create
      ],
      "InvitedJobseeker" => [
          :create
      ],
      "OfferLetter" => [
          :generate, :generate_stc_contract
      ],
      "Package" => [
          :show, :index
      ],
      "Interview" => [
          :index, :show, :generate_token, :create_bulk, :job_application, :confirm
      ],
      "Rating" => [
          :index, :show, :create, :update, :destroy
      ],
      "JobseekerHashTag" => [
          :create, :create_bulk
      ],
      "HashTag" => [
          :index
      ],
      "Unit" => [
          :index, :show, :create, :update, :destroy
      ],
      "NewSection" => [
          :index, :show, :create, :update, :destroy
      ],
      "Department" => [
          :index, :show, :create, :update, :destroy
      ],
      "BudgetedVacancy" => [
          :index, :show, :count_used_budgeted_vacancies
      ],
      "Section" => [
          :index, :show, :create, :update, :destroy
      ],
      "Office" => [
          :index, :show, :create, :update, :destroy
      ],
      "Grade" => [
          :index, :show, :create, :update, :destroy
      ],
      "HiringManager" => [
          :index, :show, :create, :update, :destroy
      ],
      "JobRequest" => [
          :index, :show, :create, :update, :destroy, :delete_bulk, :update_approvers, :request_approval
      ]
  }

  # Public Permission
  COMMON_PERMISSION = {
      "CompanySubscription" => [
          :set_activation_code
      ],
      "UserInvitation" => [
          :invite, :failure, :get_twitter_friends, :get_contacts
      ],
      "Culture" => [
          :index, :show
      ],
      "Country" => [
          :index,
          :cities,
          :show,
          :country_pdf
      ],
      "OfferApprover" => [
          :index
      ],
      "City" => [
          :index
      ],
      "Department" => [
         :index,
         :show
      ],
      "Sector" => [
          :index
      ],
      "Language" => [
          :index
      ],
      "ExperienceRange" => [
          :index
      ],
      "Benefit" => [
          :index
      ],
      "JobEducation" => [
          :index,
          :show
      ],
      "FunctionalArea" => [
          :index,
          :show
      ],
      "JobExperienceLevel" => [
          :index,
          :show
      ],
      "Tag" => [
          :index
      ],
      "Skill" => [
          :index
      ],
      "JobType" => [
          :index
      ],
      "Company" => [
          :index, :show, :jobs, :jobs_for_interview, :received_jobs, :show_analytics
      ],
      "SalaryRange" => [
          :index
      ],
      "Job" => [
          :index, :show, :statistics
      ],
      "JobApplicationStatus" => [
          :index, :statuses_with_application_count
      ],
      "AlertType" => [
          :index
      ],
      "VisaStatus" => [
          :index
      ],
      "Blog" => [
          :index, :tags, :show, :show_pdf
      ],
      "CompanyClassification" => [
          :index, :show
      ],
      "CompanyType" => [
          :index, :show
      ],
      "CompanySize" => [
          :index, :show
      ],
      "JobStatus" => [
          :index
      ],
      "PositionStatus" => [
        :index
      ],
      "PositionCvSource" => [
        :index
      ],
      "Certificate" => [
          :index, :show
      ],
      "GeoGroup" => [
        :index, :show
      ],
      "AgeGroup" => [
        :index
      ],
      "FeaturedCompany" => [
        :index
      ],
      "User" => [
        :generate_new_password_email, :valid_email, :logged_in, :refresh_mails
      ],
      "MetaTag" => [
          :index
      ],
      "Page" => [
          :index
      ],
      "PageImage" => [
          :index
      ],
      "CompanyMember" => [
          :index, :show
      ],
      "Jobseeker" => [
          :create
      ],
      "University" => [
          :index
      ],
      "CareerFair" => [
          :index, :show
      ],
      "Role" => [
        :index
      ]
  }

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
    Ability::COMMON_PERMISSION.each do |controller_name, actions|
      can actions, controller_name.constantize
    end

    return if user.nil? || !user.active || (Date.today > CompanySubscription.first.expires_at)

    # This For any user in the system
    Ability::AUTHORIZED_USER_PERMISSION.each do |controller_name, actions|
      can actions, controller_name.constantize
    end
    Ability::JOBSEEKER_PERMISSION.each do |controller_name, actions|
      can actions, controller_name.constantize
    end

    # Check role of current user
    if user.is_company_owner?
      # Add permission of company admin
      Ability::COMPANY_ADMIN_PERMISSION.each do |controller_name, actions|
        can actions, controller_name.constantize
      end

      Ability::COMPANY_OWNER_PERMISSION.each do |controller_name, actions|
        can actions, controller_name.constantize
      end

      Ability::COMPANY_USER_PERMISSION.each do |controller_name, actions|
        can actions, controller_name.constantize
      end

    elsif user.is_company_user?
      # Add permission of company user
      Ability::COMPANY_USER_PERMISSION.each do |controller_name, actions|
        can actions, controller_name.constantize
      end

    elsif user.is_recruiter?
      # Add permission of Recruiter
      Ability::RECRUITER_PERMISSION.each do |controller_name, actions|
        can actions, controller_name.constantize
      end

    end
=begin
    elsif user.is_company_admin?
      # Add permission of company owner
      Ability::COMPANY_ADMIN_PERMISSION.each do |controller_name, actions|
        can actions, controller_name.constantize
      end

      Ability::COMPANY_USER_PERMISSION.each do |controller_name, actions|
        can actions, controller_name.constantize
      end
=end

  end

end
