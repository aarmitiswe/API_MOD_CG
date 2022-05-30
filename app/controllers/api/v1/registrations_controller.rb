class Api::V1::RegistrationsController < Devise::RegistrationsController
  # def new
  #   super
  # end

  # def create
  #   super
  # end

  # To signup as Employer
  # Create User & Company if the both valid
  # TODO: Refactor it to use one permit method with nested attributes
  def signup_employer
    @company = Company.new(company_params)
    @user = User.new(user_params)
    @company.active = false
    @user.active = false
    # We don't need confirmation mail for User
    @user.skip_confirmation!

    if @company.valid? && @user.valid? && @company.save && @user.save
      CompanyUser.create(user_id: @user.id, company_id: @company.id)
      #Notification.create(user_id: @user.id, blog: 0, poll_question: 0, candidate: 0)
      @user.update_attribute(:role, "company_owner") unless @user.is_company_owner?
      @user.send_notification_to_admin
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end


  # To signup as Jobseeker for CareerFair
  def signup_jobseeker_career_fair
    @user = User.new(user_career_fair_params)
    @user.skip_confirmation_notification!

    # @user.skip_validation_birth = true
    if @user.valid? && @user.save
      @user.confirm!

      if params[:user][:jobseeker_attributes][:field_of_study]
        jobseekerEducation = JobseekerEducation.new(field_of_study: params[:user][:jobseeker_attributes][:field_of_study],
                                  jobseeker_id: @user.jobseeker.id, school: 'not defined')

        jobseekerEducation.save
      end

      @career_fair_application = CareerFairApplication.new(jobseeker_id: @user.jobseeker.id,
                                                           career_fair_id: params[:user][:career_fair_id])

      if @career_fair_application.save
        render json: @user
      else
        render json: @career_fair_application.errors, status: :unprocessable_entity
      end


    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # To signup as Jobseeker for CareerFair
  def update_jobseeker_career_fair

    @user = User.find_by_id(params[:user][:id])

    if @user.update(update_user_career_fair_params)

      if params[:user][:jobseeker_attributes][:field_of_study]
        #No School defined so added not defined
        jobseekerEducation = JobseekerEducation.new(field_of_study: params[:user][:jobseeker_attributes][:field_of_study],
                                  jobseeker_id: @user.jobseeker.id, school: 'not defined')
        jobseekerEducation.save
      end
      @career_fair_application = CareerFairApplication.new(jobseeker_id: @user.jobseeker.id,
                                                           career_fair_id: params[:user][:career_fair_id])

      if @career_fair_application.save
        render json: @user
      else
        render json: @career_fair_application.errors, status: :unprocessable_entity
      end

    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end


  # To signup as Jobseeker
  # Create user then create blank profile if user valid
  def signup_jobseeker
    @user = User.new(user_params)
    # @user.skip_validation_birth = true
    if @user.valid? && @user.save
      @jobseeker = Jobseeker.new(user_id: @user.id, nationality_id: params[:user][:nationality_id],
                                 jobseeker_type:  params[:user][:jobseeker_type], complete_step: 0)
      @jobseeker.save(validate: false)
      if params[:user][:is_graduate_program]
        JobseekerGraduateProgram.create(jobseeker_id: @jobseeker.id)
      end

      #TODO move this to callback
      # begin
      #   gibbon = Gibbon::Request.new(api_key: Rails.application.secrets['mailchimp_apikey'], symbolize_keys: true)
      #   list_id = Rails.application.secrets['mailchimp_listid']
      #   gibbon.lists(list_id).members.create(body: {email_address: @user.email, status: "subscribed", merge_fields: {FNAME: @user.first_name, LNAME: @user.last_name}})
      # rescue
      # end

      #Notification.create(user_id: @user.id, blog: 0, poll_question: 0, job: 0)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def signup_jobseeker_ats
    @user = User.new(ats_user_params)
  end

  private
  def user_params
    params[:user][:active] = true
    params[:user][:deleted] = false
    params.require(:user).permit(:first_name, :last_name, :email, :birthday, :password, :password_confirmation,
                                 :role, :gender, :country_id, :city_id, :active, :deleted)
  end



  def user_career_fair_params
    params[:user][:active] = true
    params[:user][:deleted] = false

    if params[:user][:gender]
      params[:user][:gender] = get_attribute_index("gender", params[:user][:gender])
    end

    # Temporary Password that need to be reset before login
    temp_pass = (0...8).map { (65 + rand(26)).chr }.join
    params[:user][:password] = temp_pass
    params[:user][:password_confirmation] = temp_pass
    # params[:user][:jobseeker_attributes][:career_fair_applications_attributes][:career_fair_id] = 7
    params.require(:user).permit(:first_name, :last_name, :email, :birthday, :password, :password_confirmation,
                                 :role, :gender, :country_id, :city_id, :active, :deleted,
                                 jobseeker_attributes: [:nationality_id, :jobseeker_type,
                                                        :job_experience_level_id, :job_education_id, :mobile_phone])
        .deep_merge({jobseeker_attributes:{complete_step: 0}})

  end


  def update_user_career_fair_params

    if params[:user][:gender]
      params[:user][:gender] = get_attribute_index("gender", params[:user][:gender])
    end

    params.require(:user).permit(:first_name, :last_name, :birthday, :password_confirmation,
                                 :role, :gender, :country_id, :city_id,
                                 jobseeker_attributes: [:nationality_id, :jobseeker_type,
                                                        :job_experience_level_id, :job_education_id, :mobile_phone])
        .deep_merge({jobseeker_attributes:{id: User.find(params[:user][:id]).jobseeker.id}})
  end

  def invalid_foreign_key
    render json: {error: 'foreign_key'}, status: 403
  end

  def company_params
    params[:company][:active] = true
    params[:company][:deleted] = false
    params.require(:company).permit(:name, :website, :current_city_id, :current_country_id, :address_line1,
                                    :address_line2, :phone, :contact_email, :po_box, :contact_person, :sector_id,
                                    :company_size_id, :company_type_id, :company_classification_id, :avatar, :cover,
                                    :establishment_date, :active, :deleted)
  end

  def ats_user_params
    params[:user][:active] = true
    params[:user][:deleted] = false
    params[:user][:role] = 'jobseeker'
    params[:user][:jobseeker_attributes][:complete_step] = 4

    params.require(:user).permit(:first_name, :last_name, :email, :birthday, :password, :password_confirmation,
                                 :role, :gender, :country_id, :city_id, :active, :deleted,
                                 jobseeker_attributes: [:nationality_id, :job_type_id, :mobile_phone, :visa_status_id,
                                                        :sector_id, :functional_area_id, :job_education_id, :job_category_id,
                                                        :job_experience_level_id, :expected_salary, :current_salary, :job_type_id,
                                                        :driving_license_country_id, :marital_status, :nationality_id,
                                                        :years_of_experience, :notice_period_in_month])
  end
end
