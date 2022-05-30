require 'active_support/concern'

module RegisterationConcern
  extend ActiveSupport::Concern

  included do

    # This function is called before push_to_algolia
    after_update :update_complete_step

    # STEPS_ATTRS = [
    #     ["user_first_name", "user_last_name", "user_country_id", "user_city_id", "user_birthday", "user_gender", "nationality_id"],
    #     ["sector_id", "functional_area_id", "job_experience_level_id", "years_of_experience", "current_salary"],
    #     ["job_education_id", "languages", "mobile_phone", "marital_status", "visa_status_id"],
    #     ["jobseeker_experiences", "jobseeker_educations", "jobseeker_resumes"],
    #     []
    # ]


    REGULAR_STEPS_ATTRS = [
        ["user_first_name", "user_last_name", "mobile_phone", "user_birthday", "user_gender", "marital_status", "user_country_id", "user_city_id", "nationality_id", "visa_status_id", "languages", "num_dependencies"],
        ["sector_id", "functional_area_id", "job_experience_level_id", "years_of_experience", "current_salary", "expected_salary", "jobseeker_resumes"],
        ["job_education_id", "jobseeker_educations"],
        []
    ]

    REGULAR_STEP_ATTRS_OPTIONAL = [
      [],
      ["jobseeker_experiences", "preferred_position"],
      [],
      []
    ]

    SPECIAL_STEPS_ATTRS = [
        ["user_first_name", "user_last_name", "mobile_phone", "user_birthday", "user_gender", "marital_status", "user_country_id", "user_city_id", "nationality_id", "visa_status_id", "languages"],
        ["job_education_id", "jobseeker_educations"],
        [],
        []
    ]

    SPECIAL_STEP_ATTRS_OPTIONAL = [
        ["nationality_id_number"],
        ["jobseeker_experiences"],
        [],
        []
    ]

    # TODO: remove condition of date later .. after release
    scope :active, -> {
      where("users.active = TRUE AND ((jobseekers.created_at > '2017-03-14'::date AND jobseekers.sector_id IS NOT NULL AND
            functional_area_id IS NOT NULL AND jobseekers.job_experience_level_id IS NOT NULL AND
            jobseekers.years_of_experience IS NOT NULL AND
            current_salary IS NOT NULL AND jobseekers.job_education_id IS NOT NULL AND
            jobseekers.mobile_phone IS NOT NULL AND
            jobseekers.marital_status IS NOT NULL AND jobseekers.visa_status_id IS NOT NULL) OR
            (jobseekers.created_at <= '2017-03-14'::date))")
    }

    scope :inactive_confirmed, -> { joins(:user).where("users.active = ? AND users.confirmed_at IS NOT NULL", false) }
    scope :inactive_non_confirmed, -> { joins(:user).where("users.confirmed_at IS NULL") }
    scope :inactive, -> {  joins(:user).where("users.active = ? OR users.confirmed_at IS NULL", false) }
    # scope :active_complete, -> { joins(:user).where("users.active = ? AND users.deleted = ? AND users.confirmed_at IS NOT NULL AND sector_id IS NOT NULL AND functional_area_id IS NOT NULL AND job_experience_level_id IS NOT NULL AND years_of_experience IS NOT NULL AND current_salary IS NOT NULL AND job_education_id IS NOT NULL AND mobile_phone IS NOT NULL AND marital_status IS NOT NULL AND visa_status_id IS NOT NULL", true, false).where(id: JobseekerLanguage.pluck(:jobseeker_id)) }
    scope :active_complete, -> { joins(:user).where("users.active = ? AND users.deleted = ? AND users.confirmed_at IS NOT NULL AND jobseekers.complete_step = ?", true, false, Jobseeker::COMPLETE_STEP) }
    # scope :visible_employer, -> { joins(:user).where("(users.active = ? AND users.deleted = ? AND users.confirmed_at IS NOT NULL) AND ((sector_id IS NOT NULL AND functional_area_id IS NOT NULL AND job_experience_level_id IS NOT NULL AND years_of_experience IS NOT NULL AND current_salary IS NOT NULL AND job_education_id IS NOT NULL AND mobile_phone IS NOT NULL AND marital_status IS NOT NULL AND visa_status_id IS NOT NULL AND jobseekers.id IN (?)) OR (jobseekers.created_at <= '2017-03-26'::date))", true, false, JobseekerLanguage.pluck(:jobseeker_id)) }
    scope :visible_employer, -> { joins(:user).where("(users.active = ? AND users.deleted = ?  AND users.confirmed_at IS NOT NULL) AND (jobseekers.complete_step = ? OR (jobseekers.created_at <= '2017-03-26'::date))", true, false, Jobseeker::COMPLETE_STEP) }
    # scope :active_non_complete, -> { joins(:user).where("(users.active = ? AND users.deleted = ? AND users.confirmed_at IS NOT NULL) AND (sector_id IS NULL OR functional_area_id IS NULL OR job_experience_level_id IS NULL OR years_of_experience IS NULL OR current_salary IS NULL OR job_education_id IS NULL OR mobile_phone IS NULL OR jobseekers.id NOT IN (?) OR marital_status IS NULL OR visa_status_id IS NULL)", true, false, JobseekerLanguage.pluck(:jobseeker_id)) }
    scope :active_non_complete, -> { joins(:user).where("jobseekers.complete_step < ? AND users.active = ?", Jobseeker::COMPLETE_STEP, true) }
    scope :active_non_complete_old, -> { active_non_complete.where("jobseekers.created_at <= '2017-03-26'::date")}
    scope :active_non_complete_new, -> { active_non_complete.where("jobseekers.created_at > '2017-03-26'::date")}
    scope :active_confirmed, -> { joins(:user).where("users.active = ? AND confirmed_at IS NOT NULL", true) }

    def update_complete_step
      step_flag = true
      self.complete_step ||= 0
      step_attrs, step_attrs_optional = get_step_rules
      step_attrs.each_with_index do |attrs, index|
        attrs.each do |attr|
          if self.send(attr).blank? && (step_attrs_optional[index].blank? || step_attrs_optional[index].map{|opt_attr| self.send(opt_attr).blank? }.any?)
            self.update_column(:complete_step, index)
            step_flag = false
            break
          end
        end
        break unless step_flag
      end

      # This condition for logout at step 4
      if step_flag && self.complete_step <= Jobseeker::SEMI_COMPLETE_STEP
        self.update_column(:complete_step, Jobseeker::COMPLETE_STEP)
      end
      self.update_column(:completed_at, DateTime.now) if self.is_completed? && self.completed_at.nil?
    end

    def current_step
      step_attrs, step_attrs_optional = get_step_rules
      step_attrs.each_with_index do |attrs, index|
        attrs.each do |attr|
          return index if self.send(attr).blank?
        end
      end
      return 3
    end
  end
  private

  # Selecting Rules
  def get_step_rules
    #TODO: Optimize this code
  if Rails.application.secrets['CUSTOMIZE_REGISTRATIOM_STEPS'] &&
      (self.jobseeker_type == 'coops' || self.jobseeker_type == 'summer_training')
    step_attrs = SPECIAL_STEPS_ATTRS
    step_attrs_optional = SPECIAL_STEP_ATTRS_OPTIONAL
  else
    step_attrs = REGULAR_STEPS_ATTRS
    step_attrs_optional = REGULAR_STEP_ATTRS_OPTIONAL
    end
    return step_attrs, step_attrs_optional
  end
end
