require 'api_constraints'

Rails.application.routes.draw do

  get 'hash_tags/index'

  get 'hash_tag/index'

  # routes out api module
  get '/invites/:provider/contact_callback', to: 'api/v1/user_invitations#invite'
  get '/contacts/failure', to: 'api/v1/user_invitations#failure'
  get '/api/user_invitations/twitter_friends', to: 'api/v1/user_invitations#get_twitter_friends'
  get '/api/user_invitations/get_contacts', to: 'api/v1/user_invitations#get_contacts'
  # get '/auth/twitter/callback', to: 'api/v1/user_invitations#get_twitter_friends'
  get '/api/users/auth/twitter_friends/callback', to: 'api/v1/user_invitations#get_twitter_friends'

  # return logged in user
  get '/api/users/logged_in', to: 'api/v1/users#logged_in'


  delete '/api/organizations/:oracle_id/remove', to: 'api/v1/organizations#remove'
  delete '/api/positions/:oracle_id/remove', to: 'api/v1/positions#remove'

  put '/api/job_applications/:oracle_id/update_terminate_status', to: 'api/v1/job_applications#update_terminate_status'

  # routes api module
  scope module: :v1, defaults: { format: 'json' }, constraints: ApiConstraints.new(version: 1, default: :true) do
    devise_for :users, path: '/api/users', controllers: {
        registrations: 'api/v1/registrations',
        sessions:      'api/v1/sessions',
        confirmations: 'api/v1/confirmations',
        passwords: 'api/v1/passwords'
    }
  end

  devise_scope :user do
    post 'signup_employer', to: 'api/v1/registrations#signup_employer', path: '/api/users/signup_employer'
    post 'signup_jobseeker', to: 'api/v1/registrations#signup_jobseeker', path: '/api/users/signup_jobseeker'
  end

  namespace :api, defaults: { format: 'json' } do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      resources :users, only: [:create, :update, :destroy] do
        member do
          get 'get_notification'
          put 'update_notification'
          put 'activate'
          put 'deactivate'
          post 'upload_profile_image'
          post 'upload_video'
          delete 'delete_video'
          delete 'delete_avatar'
        end

        collection do
          get 'refresh_mails'
          post 'generate_new_password_email'
          post 'valid_email'
        end
      end


      resources :bank_accounts do
        collection do
          post 'get_file_data'
        end
      end
      resources :medical_insurances do
        collection do
          post 'get_file_data'
        end
      end
      resources :jobseeker_on_board_documents

      resources :boarding_requisitions
      resources :boarding_forms do
        member do
          get 'generate_pdf'
        end
      end

      resources :roles
      resources :offer_requisitions
      resources :offer_approvers

      resources :user_invitations, only: [] do
        collection do
          post 'invite_by_email'
          post 'invite_by_twitter'
        end
      end

      # Note: We need to add param in route because If id > Jobseeker.count, then RecordNotFound error'll release
      resources :jobseekers, only: [:index, :create, :update], param: :user_id do
        member do
          get 'dashboard_summary'
          get 'profile_views_graph'
          get 'job_applications_graph'
          get 'followed_companies_graph'
          get 'job_applications_by_country'
          get 'job_applications_by_sector'
          get 'profile_views'
          get 'display_profile'
          get 'create_json_file'
          get 'display_profile_pdf'
          get 'success_probability'
          get 'completion_percentage'
          put 'update_profile_status'
          post 'update_skills'
          post 'update_tags'
          # For Employer
          get 'job_applications_history'
        end

        collection do
          get 'matched_with_graduate_program'
          get 'not_matched_with_graduate_program'
        end
      end

      resources :jobseekers, only: [] do
        resources :jobseeker_certificates, only: [:index, :show, :create, :update, :destroy] do
          member do
            post 'upload_document'
            delete 'delete_document'
          end
        end

        resources :jobseeker_educations, only: [:index, :show, :create, :update, :destroy] do
          member do
            post 'upload_document'
            delete 'delete_document'
          end
        end

        resources :jobseeker_experiences, only: [:index, :show, :create, :update, :destroy] do
          member do
            post 'upload_document'
            delete 'delete_document'
          end
        end


        resources :jobseeker_resumes, only: [:index, :show, :create, :update, :destroy] do
          collection do
            delete 'delete_bulk'
          end

          member do
            delete 'delete_document'
          end
        end


        resources :jobseeker_coverletters, only: [:index, :show, :create, :update, :destroy] do
          member do
            delete 'delete_document'
          end

          collection do
            delete 'delete_bulk'
          end
        end

        resources :saved_jobs, only: [:index, :create, :destroy], param: :job_id do
          collection do
            delete 'delete_bulk'
          end
        end

        resources :career_fair_applications, only: [:index, :create, :update, :destroy]
        resources :saved_job_searches, only: [:index, :create, :update, :destroy] do
          collection do
            delete 'delete_bulk'
          end
        end
      end

      resources :jobseeker_resumes do
        collection do
          put 'application/:job_application_id', to: 'jobseeker_resumes#application'
        end
      end


      resources :cybersource_payments, only: [:create]
      resources :demo_requests, only: [:create] do
        collection do
          post 'create_ats'
        end
      end

      resources :event_visitors, only: [:create]
      resources :tags, only: [:index]
      resources :age_groups, only: [:index]
      resources :benefits, only: [:index]
      resources :alert_types, only: [:index]
      resources :tag_types
      resources :job_types, only: [:index]
      resources :sectors, only: [:index]
      resources :languages, only: [:index]
      resources :invited_jobseekers, only: [:create]
      resources :experience_ranges, only: [:index]
      resources :offer_analyses
      resources :salary_analyses

      resources :job_application_statuses, only: [:index] do
        collection do
          get '/job_application_statuses_with_applications_count/:job_id' => 'job_application_statuses#statuses_with_application_count'
        end
      end

      resources :job_educations, only: [:index, :show]
      resources :functional_areas, only: [:index, :show]
      resources :geo_groups, only: [:index, :show]
      resources :job_experience_levels, only: [:index, :show]
      resources :skills, only: [:index]
      resources :visa_statuses, only: [:index]
      resources :job_application_logs, only: [:index]
      resources :job_history, only: [:index]

      resources :hiring_managers, only: [:index, :show, :create, :update, :destroy]
      resources :jobseeker_required_documents, only: [:index, :show, :create, :update, :destroy] do
        collection do
          post 'create_bulk'
          post 'update_bulk'
        end
      end
      resources :offer_letter_requests, only: [:index, :show, :create, :update, :destroy]
      resources :new_section, only: [:index, :show, :create, :update, :destroy]
      resources :grades, only: [:index, :show, :create, :update, :destroy]
      resources :units, only: [:index, :show, :create, :update, :destroy]
      resources :offices, only: [:index, :show, :create, :update, :destroy]
      resources :departments, only: [:index, :show, :create, :update, :destroy]
      resources :positions do
        collection do
          get 'organization/:organization_id' => 'positions#organization'
          post 'push'
        end
      end
      resources :budgeted_vacancies, only: [:index, :show, :create, :update, :destroy] do
        member do
          get 'count_used_budgeted_vacancies'
        end
      end
      resources :sections, only: [:index, :show, :create, :update, :destroy]
      resources :job_requests, only: [:index, :show, :create, :update, :destroy] do
        member do
          put 'update_approvers'
          put 'request_approval'
        end
        collection do
          delete 'delete_bulk'
        end
      end

      resource :company_subscriptions, only: [] do
        collection do
          post 'set_activation_code'
        end
      end

      resources :companies, only: [:index, :show, :update] do
        member do
          get 'show_details'
          get 'show_analytics'
          get 'jobs'
          get 'jobs_for_interview'
          get 'received_jobs'
          get 'blogs'
          get 'users'
          get 'followers'
          get 'jobs_graph'
          get 'job_applicants_graph'
          get 'job_applications_percentage'
          get 'followers_percentage'
          put 'follow'
          put 'unfollow'
          post 'upload_avatar'
          post 'upload_cover'
          post 'upload_management_video'
          delete 'delete_cover'
          delete 'delete_avatar'
          delete 'delete_management_video'
        end

        resources :branches

        resources :cultures, only: [:index, :show, :create, :update, :destroy] do
          member do
            post 'upload_avatar'
          end
        end

        resources :company_members, only: [:index, :show, :create, :update, :destroy] do
          member do
            post 'upload_avatar'
            delete 'delete_avatar'
            delete 'delete_video'
          end
        end
      end

      resources :company_users, only: [:show, :create, :update, :destroy], param: :employer_id do
        member do
          get 'users'
          get 'jobs'
          get 'blogs'
          get 'employer_details'
          put 'active'
          put 'inactive'
          #post 'push'
        end
        collection do
          post 'push'
        end
      end

      resources :salary_ranges, only: [:index]
      resources :shared_jobseekers
      resources :organizations do
        member do
          get 'positions'
          get 'jobs'
          get 'children_organizations'
        end

        collection do
          post 'push'
          post 'remove'
          post 'upload_organizations'
          get 'current_user_organizations'
        end
      end
      resources :organization_types
      resources :organization_users do
        collection do
          post 'push'
          post 'remove'
        end
      end
      resources :requisitions do
        collection do
          get 'received'
          get 'sent'
        end
      end

      resources :jobs, only: [:index, :show, :create, :update, :destroy] do
        member do
          get 'show_details'
          get 'show_details_pdf'
          get 'statistics'
          get 'analysis'
          get 'similar_jobs'
          get 'similar_companies'
          get 'similar_careers'
          get 'search_applicants_education_school'
          get 'search_applicants_education_field_study'
          get 'applicants'
          get 'get_application_stage_count'
          get 'applicants_export_csv'
          get 'applicants_export_csv_gp_junk'
          get 'junk_applicants'
          get 'job_applications_analysis'
          get 'job_applications_analysis_gp'
          get 'applicant_analytics'
          get 'suggested_jobseekers'
          get 'get_filters_with_applicants_count'
          get 'get_filters_with_applicants_count_gp'
          post 'share_url'
          get 'export_candidates'
          put 'employment_type'
          put 'close'
        end

        collection do
          get 'my_jobs'
          get 'all_jobs'
          get 'success_probability'
          get 'suggested_jobs'
          get 'featured_jobs'
          get 'top_viewed_jobs'
          delete 'delete_bulk'
          get 'export_all_candidates_requisitions'
        end


        resources :job_application_status_changes, only: [] do
          collection do
            post 'create_bulk'
            post 'create_offer_letter'
            post 'create_bulk_status_change'
            post 'create_bulk_status_change_on_search_criteria'
          end
        end
      end

      resources :cities, only: [:index]
      resources :packages, only: [:index, :show]

      resources :meta_tags, only: [:index]
      resources :countries, only: [:index, :show] do
        collection do
          get 'country_pdf'
        end
        member do
          get 'cities'
        end
      end

      resources :universities, only: [:index]
      resources :departments, only: [:index, :show]
      resources :geo_groups, only: [:index]

      resources :blogs, only: [:index, :show, :create, :update, :destroy] do
        member do
          get 'show_pdf'
          put 'like'
          put 'dislike'
          post 'upload_avatar'
          post 'upload_video'
          delete 'delete_avatar'
          delete 'delete_video'
        end

        collection do
          get 'tags'
        end

        resources :comments, only: [:create, :destroy] do
          member do
            put 'change_status'
          end
        end
      end

      resources :poll_questions, only: [:index, :show, :create, :update, :destroy] do
        member do
          post 'vote'
        end
      end

      resources :candidate_information_documents do
        member do
          get 'save_as_pdf'
          put 'update_status'
        end
      end
      resources :assessments, only: [:update]
      resources :company_classifications, only: [:index, :show]
      resources :company_types, only: [:index, :show]
      resources :company_sizes, only: [:index, :show]
      resources :certificates, only: [:index, :show]
      resources :job_statuses, only: [:index]
      resources :position_statuses, only: [:index]
      resources :position_cv_sources, only: [:index]
      resources :featured_companies, only: [:index]
      resources :page_images
      resources :meta_tags
      resources :images
      resources :pages
      resources :interviews, only: [:index, :update] do
        collection do
          post 'create_bulk'
          post 'confirm'
          get 'job_application/:job_application_id' => 'interviews#job_application'
        end
      end

      resources :job_applications, only: [:destroy] do
        collection do
          post 'create_bulk'
          post 'share_hiring_managers'
          post 'init_security_clearance'
          post 'security_clearance_result'
          post 'scan_medical_insurance'
        end

        member do
          get 'all_documents'
          get 'download_history'
          post 'create_salary_offer_analysis'
          get 'generate_hiring_contract'
          put 'approve_all_evaluation_submits'
          put 'update_extra_document'
        end

        resources :job_application_status_changes, only: [:index, :create, :update] do
          member do
            get 'get_interviews'
          end
        end
        resources :notes, only: [:index, :create]

        resources :interviews, only: [:show, :update] do

          member do
            get 'generate_token'
            put 'update_interview_committee'
          end
        end

        resources :offer_letters, only: [] do
          collection do
            post 'generate'
            post 'generate_stc_contract'
          end
        end
      end


      resources :package_broadcasts, only: [:index, :show]
      resources :jobseeker_package_broadcasts, only: [:index]
      resources :jobseeker_company_broadcasts, only: [:index, :create] do
        collection do
          post 'create_bulk'
        end
      end

      resources :folders do
        collection do
          get 'all_jobseekers'
        end

        member do
          get 'jobseekers'
          get 'sub_folders'
          get 'jobseeker_folders'
        end
      end
      resources :jobseeker_folders
      resources :assigned_folders
      resources :ratings
      resources :hash_tags, only: [:index]
      resources :jobseeker_hash_tags do
        collection do
          post 'create_bulk'
        end
      end
      resources :career_fairs do
        member do
          get 'applicants'
        end
      end
      resources :career_fair_applications
      #   Evaluation Form
      resources :evaluation_forms do
        member do
          get 'show_pdf'
        end
      end
      resources :evaluation_questions
      resources :evaluation_answers
      resources :evaluation_submits
      resources :evaluation_submit_requisitions
      resources :employer_notifications
    end
  end

end
