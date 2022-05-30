require 'active_support/concern'

module SearchParams
  extend ActiveSupport::Concern

  included do
    ransack_alias :co, :country_id_or_current_country_id
    ransack_alias :ci, :city_id_or_current_city_id
    ransack_alias :se, :sector_id
    ransack_alias :fa, :functional_area_id
    ransack_alias :jt, :job_type_id
    ransack_alias :sr, :salary_range_id
    ransack_alias :age, :age_group_id
    ransack_alias :je, :job_education_id
    ransack_alias :jel, :job_experience_level_id
    ransack_alias :com, :company_id
    ransack_alias :ti, :title
    ransack_alias :na, :name
    ransack_alias :js, :job_status_id
    ransack_alias :act, :active
    ransack_alias :del, :deleted

    # Jobseeker
    ransack_alias :full_name, :user_first_name_or_user_last_name
    ransack_alias :loc_co, :user_country_id
    ransack_alias :loc_ci, :user_city_id
    ransack_alias :com_na, :jobseeker_experiences_company_name
    ransack_alias :pos, :jobseeker_experiences_position
    ransack_alias :app_status, :job_application_status_id
    ransack_alias :yoe, :years_of_experience
    ransack_alias :la, :language_id
    # not_lteq 1,2,3,12
    ransack_alias :not, :notice_period_in_month
    ransack_alias :nat, :nationality_id
    ransack_alias :ge, :user_gender
    ransack_alias :vi, :visa_status_id
  end
end