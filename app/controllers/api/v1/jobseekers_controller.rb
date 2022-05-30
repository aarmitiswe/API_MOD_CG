class Api::V1::JobseekersController < ApplicationController
  include DateHelper
  include MapperAttributes
  include AdjustSearchParamsHelper
  include HtmlWithArrayHelper

  skip_before_action :authenticate_user, only: [:create]

  before_action :set_jobseeker, only: [:display_profile,
                                       :update,
                                       :update_skills,
                                       :update_tags,
                                       :dashboard_summary,
                                       :profile_views_graph,
                                       :job_applications_graph,
                                       :followed_companies_graph,
                                       :job_applications_by_country,
                                       :job_applications_by_sector,
                                       :profile_views,
                                       :display_profile_pdf,
                                       :completion_percentage,
                                       :job_applications_history]

  before_action :update_search_params, only: [:index]

  # before_action :jobseeker_owner, only: [:display_profile, :display_profile_pdf, :completion_percentage,
  #                                        :dashboard_summary, :profile_views_graph, :job_applications_graph,
  #                                        :followed_companies_graph, :job_applications_by_country,
  #                                        :job_applications_by_sector, :profile_views, :update, :update_skills,
  #                                        :update_tags]

  # This index for emaployer & return jobseekers order by viewers by default
  # This action for search through Jobseekers also
  # order values viewers & current_salary & expected_salary & years_experience
  def index
    #params[:order] ||= "last_sign_in"
    params[:q] ||= {}
    # @q = if params[:q][:la_in].present?
    #        Jobseeker.active.joins(:languages).send("order_by_#{params[:order]}").ransack(params[:q])
    #      elsif params[:order].present?
    #        Jobseeker.active.send("order_by_#{params[:order]}").ransack(params[:q])
    #      else
    #        Jobseeker.ransack(params[:q])
    #      end
    @q = Jobseeker.order(created_at: :desc).ransack(params[:q])
    @jobseekers = @q.result(distinct: true).includes([:jobseeker_resumes]).paginate(page: params[:page])
    render json: @jobseekers, meta: pagination_meta(@jobseekers), each_serializer: JobseekerListSerializer, ar: params[:ar]
    # if params[:order] == 'viewers'
    #   @jobseekers = @q.result(distinct: true).includes([:jobseeker_resumes])
    #   render json: @jobseekers, each_serializer: JobseekerListSerializer, ar: params[:ar]
    # else
    #
    #   if params[:page].nil?
    #     params[:page] = 1
    #   end
    #
    #   @jobseekers = @q.result(distinct: true).paginate(page: params[:page])
    #   render json: @jobseekers, meta: pagination_meta(@jobseekers), each_serializer: JobseekerListSerializer, ar: params[:ar]
    # end
  end

  def matched_with_graduate_program
    @jobseekers = Jobseeker.matched_criteria_graduate_program.paginate(page: params[:page])
    render json: @jobseekers, meta: pagination_meta(@jobseekers), each_serializer: JobseekerListSerializer, ar: params[:ar]
  end

  def not_matched_with_graduate_program
    @jobseekers = Jobseeker.not_matched_criteria_graduate_program.paginate(page: params[:page])
    render json: @jobseekers, meta: pagination_meta(@jobseekers), each_serializer: JobseekerListSerializer, ar: params[:ar]
  end

  def update_profile_status
    @jobseeker = Jobseeker.find_by_user_id(params[:user_id])
    if @jobseeker.update(complete_step: Jobseeker::COMPLETE_STEP, completed_at: DateTime.now)
      render json: @jobseeker, serializer: JobseekerProfileSerializer
    else
      render json: @jobseeker.errors, status: :unprocessable_entity
    end
  end

  def create_json_file

    @jobseekers = Jobseeker.where("updated_at > ? ", DateTime.now-1.month).all
    render json: @jobseekers, each_serializer: JobseekerProfileSerializer
  end

  def display_profile
    if @current_user.is_employer? || @jobseeker.is_completed?
      if @current_user.is_employer?
        JobseekerProfileView.create(jobseeker_id: @jobseeker.id,
                                    company_user_id: CompanyUser.find_by(company_id: @current_company.id,
                                                                         user_id: @current_user.id).id,
                                    company_id: @current_company.id)
        # This condition to add mathcing percentage between Job & Jobseeker
        if params[:job_id] && @job = Job.find_by_id(params[:job_id])
          @jobseeker = Jobseeker.add_matching_percentage @jobseeker, @job
          job_application = @jobseeker.job_applications.where(job_id: @job.id).first
          job_application_status = JobApplicationStatus.find_by_status("Reviewed")
          if job_application && job_application.job_application_status_changes.blank?
            JobApplicationStatusChange.create(job_application_id: job_application.id,
                                              job_application_status_id: job_application_status.id,
                                              employer_id: @current_user.id, jobseeker_id: @jobseeker.user.id,
                                              comment: "Your application has reviewed by the employer")
          end
        end
      end

      jobseeker_json = JobseekerProfileSerializer.new(@jobseeker, root: :jobseeker_profile)
      jobseeker_json_hash = {jobseeker_profile: {}}
      jobseeker_json_hash[:jobseeker_profile] = jobseeker_json.serializable_object({job_id: params[:job_id], ar: params[:ar]})

      # jobseeker_json_res = JSON.parse(jobseeker_json)
      jobseeker_json_res = jobseeker_json_hash
      # TODO: Refactor this part .. Dirty Code
      begin
        unless params[:highlights].blank?
          temp_word = jobseeker_json[(jobseeker_json =~ /#{params[:highlights]}/i)...((jobseeker_json =~ /#{params[:highlights]}/i) + params[:highlights].length)]
          dub_jobseeker_json = JSON.parse(jobseeker_json.dup)
          jobseeker_json = jobseeker_json.gsub(/#{params[:highlights]}/i, "<em>#{temp_word}</em>")
          jobseeker_json_res = JSON.parse(jobseeker_json)
          jobseeker_json_res["jobseeker_profile"]["avatar"] = dub_jobseeker_json["jobseeker_profile"]["avatar"]
          jobseeker_json_res["jobseeker_profile"]["video"] = dub_jobseeker_json["jobseeker_profile"]["video"]
          jobseeker_json_res["jobseeker_profile"]["video_screenshot"] = dub_jobseeker_json["jobseeker_profile"]["video_screenshot"]
          jobseeker_json_res["jobseeker_profile"]["social_media"] = dub_jobseeker_json["jobseeker_profile"]["social_media"]

          if dub_jobseeker_json["jobseeker_profile"]["work_experience"]
            jobseeker_json_res["jobseeker_profile"]["work_experience"].each_with_index do |w_e, index|
              w_e["document"] = dub_jobseeker_json["jobseeker_profile"]["work_experience"][index]["document"]
            end
          end

          if dub_jobseeker_json["jobseeker_profile"]["education"]
            jobseeker_json_res["jobseeker_profile"]["education"].each_with_index do |edu, index|
              edu["document"] = dub_jobseeker_json["jobseeker_profile"]["education"][index]["document"]
            end
          end

          if dub_jobseeker_json["jobseeker_profile"]["resumes"]
            jobseeker_json_res["jobseeker_profile"]["resumes"].each_with_index do |res, index|
              res["document"] = dub_jobseeker_json["jobseeker_profile"]["resumes"][index]["document"]
            end
          end

          if dub_jobseeker_json["jobseeker_profile"]["coverletters"]
            jobseeker_json_res["jobseeker_profile"]["coverletters"].each_with_index do |cov, index|
              cov["document"] = dub_jobseeker_json["jobseeker_profile"]["coverletters"][index]["document"]
            end
          end

          if dub_jobseeker_json["jobseeker_profile"]["certificate"]
            jobseeker_json_res["jobseeker_profile"]["certificate"].each_with_index do |cer, index|
              cer["document"] = dub_jobseeker_json["jobseeker_profile"]["certificate"][index]["document"]
            end
          end

          if dub_jobseeker_json["jobseeker_profile"]["current_experience"]
            jobseeker_json_res["jobseeker_profile"]["current_experience"]["document"] = dub_jobseeker_json["jobseeker_profile"]["current_experience"]["document"]
          end
        end
      rescue Exception => e
        puts e
      end

      render json: jobseeker_json_res

      # render json: @jobseeker, serializer: JobseekerProfileSerializer, job_id: params[:job_id], ar: params[:ar]
    else
      # render json: JobseekerProfileSerializer.new(@jobseeker, serializer_options: {job_id: params[:job_id], ar: params[:ar]}).to_json
      # render json: JobseekerProfileSerializer.new(@jobseeker, {job_id: params[:job_id], ar: params[:ar]}).to_json
      render json: @jobseeker, serializer: JobseekerProfileSerializer, job_id: params[:job_id], ar: params[:ar]
    end
  end

  # GET /success_probability
  def success_probability
    @job = Job.find(params[:job_id])
    render json: {response: @job.calculate_probability(@current_user.jobseeker)}
  end

  def save_as_pdf jobseeker
    @jobseeker = jobseeker
    pdf = WickedPdf.new.pdf_from_string(
        render_to_string('api/v1/jobseekers/display_profile_pdf.html.erb', layout: false)
    )
    pdf
  end

  def display_profile_pdf
    # render template: "api/v1/jobseekers/display_profile_pdf", handlers: [:erb], formats: [:html]
    # pdf = WickedPdf.new.pdf_from_string(
    #     render_to_string('api/v1/jobseekers/display_profile_pdf.html.erb', layout: false)
    # )
    # send_data pdf, filename: "resume.pdf", type: "application/pdf", disposition: "attachment"
    render pdf: 'bloovo_resume', handlers: [:erb], formats: [:html]
  end

  def completion_percentage
    render json: {jobseeker: {completion_percentage: @jobseeker.complete_profile_percentage}}
  end

  # GET /jobseekers/1/dashboard_summary

  def dashboard_summary
    respond_with @jobseeker,
                 serializer: JobseekerApplicationsSummarySerializer,
                 root: :summary
  end

  # GET /jobseekers/1/profile_views_graph

  def profile_views_graph
    respond_with @jobseeker,
                 serializer: JobseekerProfileViewsGraphSerializer,
                 root: :profile_views_graph
  end

  def job_applications_history
    @job_applications = @jobseeker.job_applications.paginate(page: params[:page])
    render json: @job_applications, each_serializer: JobApplicationFullDetailsSerializer, root: :job_applications, ar: params[:ar], meta: pagination_meta(@job_applications)
  end

  # GET /jobseekers/1/job_applications_graph

  def job_applications_graph
    respond_with @jobseeker,
                 serializer: JobseekerApplicationsGraphSerializer,
                 root: :job_applications_graph
  end

  # GET /jobseekers/1/followed_companies_graph

  def followed_companies_graph
    respond_with @jobseeker,
                 serializer: JobseekerFollowGraphSerializer,
                 root: :followed_companies_graph
  end

  # GET /jobseekers/1/job_applications_by_country

  def job_applications_by_country
    @applied_jobs = @jobseeker.applied_jobs_by_country

    respond_with @applied_jobs,
                 each_serializer: JobseekerApplicationsByCountrySerializer,
                 root: :job_applications_by_country, ar: params[:ar]
  end

  # GET /jobseekers/1/job_applications_by_sector

  def job_applications_by_sector
    @applied_jobs = @jobseeker.applied_jobs_by_sector

    respond_with @applied_jobs,
                 each_serializer: JobseekerApplicationsBySectorSerializer,
                 root: :job_applications_by_sector, ar: params[:ar]
  end

  # GET /jobseekers/1/profile_views

  def profile_views
    # Uniq companies list with most recently viewed date
    @profile_views = JobseekerProfileView.where(jobseeker_id: @jobseeker.id)
                         .select("DISTINCT company_id, MAX(created_at) as view_date")
                         .group('company_id')
                         .order('MAX(created_at) DESC')
    respond_with @profile_views,
                 each_serializer: JobseekerProfileViewSerializer,
                 root: :profile_views, ar: params[:ar]
  end

  # PATCH/PUT /jobseekers/1
  # PATCH/PUT /jobseekers/1.json
  # This action is called for the following sections: (personal, contact, address, myInfo, summary)
  def update
    if @jobseeker.update(update_applicant_jobseeker_params)
      # This Call because we added jobseeker_exp & edu _resume for complete profile
      # TODO: Refactor later
      @jobseeker.update_complete_step
      render json: @jobseeker, serializer: JobseekerProfileSerializer, ar: params[:ar]
    else
      render json: @jobseeker.errors, status: :unprocessable_entity
    end
  end

  # POST /jobseeker/1/update_skills
  # POST /jobseeker/1/update_skills.json
  # Body as the following {jobseeker: {skills: [{id: 1, name: "Ruby", level: 2}, {id: null, name: "Java", level: 3}]}}
  # if add new skill or edit name exist one .. should send id: nil
  # if update level
  # if delete skill
  # if add exist skill
  def update_skills_with_params is_request=true
    return nil if params[:jobseeker].blank? || params[:jobseeker][:skills].blank?

    all_skill_ids = params[:jobseeker][:skills].map { |sk| sk[:id].to_i }.uniq.compact || [-1]
    all_skill_ids = [-1] if all_skill_ids.blank?

    params[:jobseeker][:skills].each do |skill|
      next if skill[:name].blank?
      # new skill
      if skill[:id].blank?
        new_skill = Skill.where('lower(name) = ?', skill[:name].downcase).first || Skill.create(name: skill[:name])
        new_jobseeker_skill = JobseekerSkill.find_or_create_by(jobseeker_id: @jobseeker.id, skill_id: new_skill.id)
        new_jobseeker_skill.update(level: skill[:level] || 1)
        all_skill_ids.push(new_jobseeker_skill.skill_id)
      else
        exist_jobseeker_skill = JobseekerSkill.find_by(skill_id: skill[:id], jobseeker_id: @jobseeker.id)
        # Update level
        if exist_jobseeker_skill
          exist_jobseeker_skill.update(level: skill[:level] || 1)
        else
          # Create new assigned skill
          JobseekerSkill.create!(jobseeker_id: @jobseeker.id, skill_id: skill[:id], level: skill[:level] || 1)
        end
      end
    end
    # Delete jobseeker_skills
    @jobseeker.jobseeker_skills.where("skill_id NOT IN (?)", all_skill_ids).destroy_all
    @jobseeker.reload

    if is_request
      render json: @jobseeker.jobseeker_skills
    else
      return @jobseeker
    end
  end


  def update_skills
    update_skills_with_params true
  end

  # POST /jobseeker/1/update_tags
  # POST /jobseeker/1/update_tags.json
  # Body as the following {jobseeker: {tags: [{id: 1, name: "Programming"}, {id: null, name: "Football"}]}}
  # if add new tag or edit name exist one .. should send id: nil
  # if delete tag
  # if add exist tag
  def update_tags
    all_tags_ids = params[:jobseeker][:tags].map { |tag| tag[:id] }.uniq.compact || [-1]
    all_tags_ids = [-1] if all_tags_ids.blank?
    # This loop add new tag, add new exist tag
    params[:jobseeker][:tags].each do |tag|
      next if tag[:name].blank?
      # new tag
      if tag[:id].nil?
        tag_type = TagType.find_by_name("Users")
        new_tag = Tag.where('lower(name) = ?', tag[:name].downcase).where(tag_type_id: tag_type.id).first || Tag.create(name: tag[:name], tag_type_id: tag_type.id)

        new_jobseeker_tag = JobseekerTag.find_or_create_by(jobseeker_id: @jobseeker.id,
                                                           tag_id: new_tag.id)
        all_tags_ids.push(new_jobseeker_tag.tag_id)
      else
        # create new relation (add new exist tag)
        JobseekerTag.find_or_create_by!(jobseeker_id: @jobseeker.id, tag_id: tag[:id])
      end
    end
    # Delete jobseeker_tags
    @jobseeker.jobseeker_tags.where("tag_id NOT IN (?)", all_tags_ids).destroy_all

    render json: @jobseeker.tags
  end

  def create
    @user = User.new(user_params)
    @jobseeker = Jobseeker.new(create_applicant_jobseeker_params)
    if @user.valid?
      if @jobseeker.valid?
        @user.skip_confirmation!
        ActiveRecord::Base.transaction do
          @user.save
          @jobseeker.user_id = @user.id
          @jobseeker.save(validate: false)
          update_skills_with_params(false)
          Notification.create(user_id: @user.id, blog: 0, poll_question: 0, job: 0)
          render json: @jobseeker, serializer: JobseekerProfileSerializer, ar: params[:ar]
        end
      else
        render json: @jobseeker.errors, status: :unprocessable_entity
      end
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def update_terminate_status
    @jobseeker = User.find_by(oracle_id: params[:oracle_id]).try(:jobseeker) || Jobseeker.find_by(oracle_id: params[:oracle_id])
    if @jobseeker.nil?
      render json: {errors: {jobseeker: 'Not Found'}}, status: :not_found
    elsif params[:jobseeker][:terminated] == true
      params[:jobseeker][:terminated_at] = DateTime.now
    else
      params[:jobseeker][:terminated_at] = nil
    end

    if @jobseeker.update(jobseeker_params)
      render json: @jobseeker, serializer: JobseekerProfileSerializer, ar: params[:ar]
    else
      render json: @jobseeker.errors, status: :unprocessable_entity
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_jobseeker
    @jobseeker = User.active.find_by_id(params[:user_id]).try(:jobseeker)
    render json: {errors: {jobseeker: 'Not Found'}}, status: :not_found if @jobseeker.nil?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def jobseeker_params
    update_params
    params.require(:jobseeker).permit(:google_plus_page_url, :linkedin_page_url, :facebook_page_url, :skype_id,
                                      :twitter_page_url, :mobile_phone, :home_phone, :visa_status_id, :preferred_position,
                                      :current_city_id, :current_country_id, :zip, :address_line1, :address_line2,
                                      :sector_id, :functional_area_id, :job_education_id, :job_category_id,
                                      :job_experience_level_id, :expected_salary, :current_salary, :job_type_id,
                                      :driving_license_country_id, :marital_status, :nationality_id,
                                      :years_of_experience, :summary, :notice_period_in_month, :num_dependencies,
                                      :terminated_at,
                                      user_attributes: [:first_name, :last_name, :middle_name, :email, :birthday,
                                                        :gender, :country_id, :city_id, :avatar, :video],
                                      language_ids: [])
  end

  def set_default_values
=begin
    params[:jobseeker][:user_attributes][:active] = true
    params[:jobseeker][:user_attributes][:deleted] = false
    params[:jobseeker][:user_attributes][:role] = 'jobseeker'
=end
    params[:jobseeker][:complete_step] = 4
  end

  def create_applicant_jobseeker_params
    #update_params
    set_default_values
    params.require(:jobseeker).permit(:id, :google_plus_page_url, :linkedin_page_url, :facebook_page_url, :skype_id,
                                      :twitter_page_url, :mobile_phone, :id_number, :home_phone, :visa_status_id, :complete_step,
                                      :current_city_id, :current_country_id, :zip, :address_line1, :address_line2,
                                      :sector_id, :functional_area_id, :job_education_id, :job_category_id, :num_dependencies,
                                      :job_experience_level_id, :expected_salary, :current_salary, :job_type_id,
                                      :driving_license_country_id, :marital_status, :nationality_id, :preferred_position,
                                      :years_of_experience, :summary, :visa_status, :notice_period_in_month,
                                      :document_nationality_id, :nationality_id_number, :employment_type, :candidate_type,
                                      jobseeker_resumes_attributes: [:id, :title, :document, :is_deleted => false, :default => true],
                                      jobseeker_on_board_documents_attributes: [:id, :document, :type_of_document, :_destroy],
                                      medical_insurances_attributes: [:id, :english_name, :arabic_name, :birthday, :id_number, :nationality_id, :start_date, :end_date, :relation, :_destroy],
                                      bank_accounts_attributes: [:id, :account_number, :iban_number, :bank_name, :_destroy],
                                      jobseeker_coverletters_attributes: [:id, :title, :document, :description, :is_deleted => false, :default => true],
                                      jobseeker_educations_attributes: [:id, :job_education_id, :country_id, :city_id, :grade, :school, :field_of_study, :from, :to, :max_grade, :degree_type, :university_id, :document],
                                      jobseeker_experiences_attributes: [:id, :from, :to, :sector_id, :country_id, :city_id, :position, :company_name, :company_id, :department, :description],
                                      user_attributes: [:id, :first_name, :middle_name, :last_name, :email, :password, :password_confirmation, :birthday, :gender, :role_id, :country_id, :city_id, :avatar, :video, :active, :deleted],
                                      jobseeker_skills_attributes: [:id, :skill_id],
                                      language_ids: [])
  end

  def update_applicant_jobseeker_params
    update_params
    params.require(:jobseeker).permit(:id, :google_plus_page_url, :linkedin_page_url, :facebook_page_url, :skype_id,
                                      :twitter_page_url, :mobile_phone, :home_phone, :visa_status_id, :complete_step,
                                      :current_city_id, :current_country_id, :zip, :address_line1, :address_line2,
                                      :sector_id, :functional_area_id, :job_education_id, :job_category_id,
                                      :job_experience_level_id, :expected_salary, :current_salary, :job_type_id,
                                      :document_nationality_id, :nationality_id_number,:num_dependencies,
                                      :driving_license_country_id, :marital_status, :nationality_id, :preferred_position,
                                      :years_of_experience, :summary, :visa_status, :notice_period_in_month, :visa_code, :num_dependencies,
                                      jobseeker_resumes_attributes: [:id, :title, :document, :is_deleted, :default, :_destroy],
                                      jobseeker_on_board_documents_attributes: [:id, :document, :type_of_document, :_destroy],
                                      medical_insurances_attributes: [:id, :english_name, :arabic_name, :birthday, :id_number, :nationality_id, :start_date, :end_date, :relation, :_destroy],
                                      bank_accounts_attributes: [:id, :account_number, :iban_number, :bank_name, :_destroy],
                                      jobseeker_coverletters_attributes: [:id, :title, :document, :description, :is_deleted, :default, :_destroy],
                                      jobseeker_educations_attributes: [:id, :job_education_id, :country_id, :city_id, :grade, :school, :field_of_study, :from, :to, :max_grade, :degree_type, :university_id, :_destroy, :document],
                                      jobseeker_graduate_program_attributes: [:id, :ielts_score, :ielts_document, :toefl_score, :toefl_document, :_destroy],
                                      jobseeker_experiences_attributes: [:id, :from, :to, :sector_id, :country_id, :city_id, :position, :company_name, :company_id, :department, :description, :_destroy],
                                      user_attributes: [:id, :first_name, :last_name, :middle_name, :birthday, :gender, :role_id, :country_id, :city_id, :avatar, :video, :active, :deleted],
                                      jobseeker_skills_attributes: [:id, :skill_id],
                                      language_ids: [])
  end

  def update_params
    if params[:jobseeker][:user_attributes]
      if params[:jobseeker][:user_attributes][:gender]
        params[:jobseeker][:user_attributes][:gender] = get_attribute_index("gender", params[:jobseeker][:user_attributes][:gender])
      end

      if params[:jobseeker][:user_attributes][:dob_day]
        params[:jobseeker][:user_attributes][:birthday] = mapper_birthday(params[:jobseeker][:user_attributes])
      end
    end

    if params[:jobseeker][:jobseeker_experiences_attributes]
      params[:jobseeker][:jobseeker_experiences_attributes].each{ |exp| exp[:description] = convert_array_to_html_string(exp[:description]) if exp[:description] }
    end

    # params[:jobseeker][:languages] = params[:jobseeker][:languages].join(",") if params[:jobseeker][:languages]
  end

  def update_search_params
    update_search_params_jobseekers
    update_text_params
  end

  def user_params
    params[:user][:active] = true
    params[:user][:deleted] = false
    params[:user][:role_id] = Role.find_by_name('Jobseeker').id

    params.require(:user).permit(:first_name, :last_name, :email, :birthday, :password, :password_confirmation,
                                 :role_id, :gender, :country_id, :city_id, :active, :deleted)
  end

  def jobseeker_owner
    if @current_user.is_jobseeker? && (params[:user_id].nil? || @current_user.id != params[:user_id].to_i)
      @current_ability.cannot params[:action].to_sym, Jobseeker
      authorize!(params[:action].to_sym, Jobseeker)
    end
  end
end
