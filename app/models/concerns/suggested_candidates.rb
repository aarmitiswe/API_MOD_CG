require 'active_support/concern'

module SuggestedCandidates
  extend ActiveSupport::Concern

  included do

    include MatchingPercentageAttributes
    ATTR_WEIGHT = MatchingPercentageAttributes::ATTR_WEIGHT

    scope :join_with_associations, -> {
      joins("INNER JOIN users ON jobseekers.user_id = users.id")
          .joins("LEFT OUTER JOIN jobseeker_certificates ON jobseeker_certificates.jobseeker_id = jobseekers.id")
    }

    scope :select_order_params, -> {
      select("DISTINCT ON (jobseekers.id) jobseekers.*, jobseekers.current_salary AS cur_sal, jobseekers.expected_salary AS exp_sal, jobseekers.years_of_experience AS yoe, jobseekers.id AS j_id")
    }

    scope :country_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN users.country_id IS NOT NULL AND users.country_id != 0 AND users.country_id =#{job.country_id || -1} THEN #{ATTR_WEIGHT[:country]} ELSE 0 END AS country_percentage")
    }

    scope :city_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN users.city_id IS NOT NULL AND users.city_id != 0 AND users.city_id =#{job.city_id || -1} THEN #{ATTR_WEIGHT[:city]} ELSE 0 END AS city_percentage")
    }

    scope :sector_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN jobseekers.sector_id IS NOT NULL AND jobseekers.sector_id != 0 AND jobseekers.sector_id =#{job.sector_id || -1} THEN #{ATTR_WEIGHT[:sector]} ELSE 0 END AS sector_percentage")
    }

    scope :functional_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN jobseekers.functional_area_id IS NOT NULL AND jobseekers.functional_area_id != 0 AND jobseekers.functional_area_id =#{job.functional_area_id || -1} THEN #{ATTR_WEIGHT[:functional]} ELSE 0 END AS functional_percentage")
    }

    scope :position_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN jobseekers.id IN (#{job.jobseeker_ids_has_common_title.join(',')}) THEN #{ATTR_WEIGHT[:position]} ELSE 0 END AS position_percentage")
    }

    scope :years_experience_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN jobseekers.years_of_experience BETWEEN #{job.experience_from || 0} AND  #{job.experience_to || 0} THEN #{ATTR_WEIGHT[:years_experience]} ELSE 0 END AS years_experience_percentage")
    }

    scope :job_experience_level_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN jobseekers.job_experience_level_id=#{job.job_experience_level_id || 0} THEN #{ATTR_WEIGHT[:job_experience_level]} ELSE 0 END AS job_experience_level_percentage")
    }

    scope :job_education_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN jobseekers.job_education_id=#{job.job_education_id || 0} THEN #{ATTR_WEIGHT[:job_education]} ELSE 0 END AS job_education_percentage")
    }

    scope :expected_salary_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN jobseekers.expected_salary BETWEEN #{job.salary_range.try(:salary_from) || 0} AND #{job.salary_range.try(:salary_to) || 0} THEN #{ATTR_WEIGHT[:expected_salary]} ELSE 0 END AS expected_salary_percentage")
    }

    scope :job_type_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN jobseekers.job_type_id=#{job.job_type_id || 0} THEN #{ATTR_WEIGHT[:job_type]} ELSE 0 END AS job_type_percentage")
    }

    scope :skills_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN jobseekers.id IN (#{job.jobseeker_ids_has_common_skills.join(',')}) THEN #{ATTR_WEIGHT[:skills]} ELSE 0 END AS skills_percentage")
    }

    scope :nationality_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN jobseekers.nationality_id IN (#{(job.geo_country_ids << -1).join(',')}) THEN #{ATTR_WEIGHT[:nationality]} ELSE 0 END AS nationality_percentage")
    }

    scope :age_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN '#{job.age_group_id || 0}' = '0' OR users.birthday BETWEEN '#{Date.today - (job.age_group.try(:max_age) || 0).year}'::date AND '#{Date.today - (job.age_group.try(:min_age) || 0).year}'::date THEN #{ATTR_WEIGHT[:age]} ELSE 0 END AS age_percentage")
    }

    scope :gender_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN '#{job.gender || 0}' = '0' OR users.gender=#{job.gender || -1} THEN #{ATTR_WEIGHT[:gender]} ELSE 0 END AS gender_percentage")
    }

    scope :marital_status_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN '#{job.marital_status || 'any'}' = 'any' OR jobseekers.marital_status = '#{job.marital_status || -1}' THEN #{ATTR_WEIGHT[:marital_status]} ELSE 0 END AS marital_status_percentage")
    }

    scope :visa_status_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN '#{job.visa_status_id || 0}' = '0' OR jobseekers.visa_status_id = '#{job.visa_status_id || -1}' THEN #{ATTR_WEIGHT[:visa_status]} ELSE 0 END AS visa_status_percentage")
    }

    scope :driving_license_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN '#{job.license_required || 0}' = '0' OR jobseekers.driving_license_country_id IS NOT NULL THEN #{ATTR_WEIGHT[:driving_license]} ELSE 0 END AS driving_license_percentage")
    }

    # TODO: Update Languages when update tables
    scope :languages_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN jobseekers.id IN (#{job.jobseeker_ids_has_common_languages.join(',')}) THEN #{ATTR_WEIGHT[:languages]} ELSE 0 END AS languages_percentage")
    }

    scope :join_date_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN 1=1 THEN #{ATTR_WEIGHT[:join_date]} ELSE 0 END AS join_date_percentage")
    }

    scope :certificates_percentage, -> (job) {
      select("jobseekers.*, CASE WHEN jobseeker_certificates.certificate_id IN (#{(job.certificate_ids << -1).join(',')}) THEN #{ATTR_WEIGHT[:certificates]} ELSE 0 END AS certificates_percentage")
    }

    scope :error_percentage, -> (job) {
      select("jobseekers.*,  -1 + 3 * CASE WHEN (((CASE WHEN ((users.country_id IS NOT NULL AND users.country_id != 0 AND users.country_id =#{job.country_id || -1}) OR (users.city_id IS NOT NULL AND users.city_id != 0 AND users.city_id =#{job.city_id || -1})) THEN 1 ELSE 0 END) + (CASE WHEN (jobseekers.sector_id IS NOT NULL AND jobseekers.sector_id != 0 AND jobseekers.sector_id =#{job.sector_id || -1}) THEN 1 ELSE 0 END) + (CASE WHEN (jobseekers.functional_area_id =#{job.functional_area_id || 0}) THEN 1 ELSE 0 END) + (CASE WHEN jobseekers.nationality_id IN (#{(job.geo_country_ids << -1).join(',')}) THEN 1 ELSE 0 END) + (CASE WHEN jobseekers.years_of_experience BETWEEN #{job.experience_from || 0} AND  #{job.experience_to || 0} THEN 1 ELSE 0 END) + (CASE WHEN jobseekers.id IN (#{job.jobseeker_ids_has_common_title.join(',')}) THEN 1 ELSE 0 END) - 1 ) > 0) THEN ((CASE WHEN ((users.country_id IS NOT NULL AND users.country_id != 0 AND users.country_id =#{job.country_id || -1}) OR (users.city_id IS NOT NULL AND users.city_id != 0 AND users.city_id =#{job.city_id || -1})) THEN 1 ELSE 0 END) + (CASE WHEN (jobseekers.sector_id IS NOT NULL AND jobseekers.sector_id != 0 AND jobseekers.sector_id =#{job.sector_id || -1}) THEN 1 ELSE 0 END) + (CASE WHEN (jobseekers.functional_area_id =#{job.functional_area_id || 0}) THEN 1 ELSE 0 END) + (CASE WHEN jobseekers.nationality_id IN (#{(job.geo_country_ids << -1).join(',')}) THEN 1 ELSE 0 END) + (CASE WHEN jobseekers.years_of_experience BETWEEN #{job.experience_from || 0} AND  #{job.experience_to || 0} THEN 1 ELSE 0 END) + (CASE WHEN jobseekers.id IN (#{job.jobseeker_ids_has_common_title.join(',')}) THEN 1 ELSE 0 END) - 1 ) ELSE 0 END AS error_percentage")
    }

    scope :all_percentage, -> (job, fileter_params={}) {
      ATTR_WEIGHT.keys.inject(Jobseeker.join_with_associations) {|res, key| res.send *"#{key.to_s}_percentage", job}.ransack(fileter_params).result
    }

    # This scope used for three places:
    # - Calculate percentage for all jobseekers & save it in suggested_candidates table
    # - Cal. percentage for applicants
    # - Get applicants in range of Matching Percentage
    scope :calculate_matching_percentage, -> (job, fileter_params = {}, min_mp = 0, max_mp = 100, order="matching_percentage") {
      order_attr = case order
                     when "matching_percentage"
                       "matching_percentage"
                     when "current_salary"
                       "f_cur_sal"
                     when "expected_salary"
                       "f_exp_sal"
                     when "years_of_experience"
                       "f_yoe"
                     when "id"
                       nil
                   end

      order_str = order_attr.present? ? "final_jobseekers.#{order_attr} DESC" : "final_jobseekers.f_j_id DESC"

      "#{ATTR_WEIGHT.keys.map { |s| "matched_jobseekers.#{s.to_s}_percentage" } * ' + '}"

      select("final_jobseekers.*, final_jobseekers.f_j_id, final_jobseekers.matching_percentage, final_jobseekers.f_cur_sal, final_jobseekers.f_exp_sal, final_jobseekers.f_yoe").from(
          select("matched_jobseekers.*, matched_jobseekers.j_id AS f_j_id, matched_jobseekers.cur_sal AS f_cur_sal, matched_jobseekers.exp_sal AS f_exp_sal, matched_jobseekers.yoe AS f_yoe, #{ATTR_WEIGHT.keys.map { |s| "matched_jobseekers.#{s.to_s}_percentage AS #{s.to_s}_percentage" } * ' , '} ,(#{ATTR_WEIGHT.keys.map { |s| "matched_jobseekers.#{s.to_s}_percentage" } * ' + '}) AS matching_percentage")
              .from(Jobseeker.select_order_params.all_percentage(job, fileter_params).order("jobseekers.id"), :matched_jobseekers), :final_jobseekers)
          .where("final_jobseekers.matching_percentage >= ? AND final_jobseekers.matching_percentage <= ?", min_mp, max_mp)
          .order(order_str)
    }

    scope :internal_order_by_matching_percentage, -> {
      order("final_jobseekers.matching_percentage, final_jobseekers.f_j_id DESC")
    }

    scope :internal_order_by_current_salary, -> {
      order("final_jobseekers.f_cur_sal ASC NULLS LAST")
    }

    scope :internal_order_by_expected_salary, -> {
      order("final_jobseekers.f_exp_sal ASC NULLS LAST")
    }

    scope :internal_order_by_years_of_experience, -> {
      order("final_jobseekers.f_yoe DESC NULLS LAST")
    }

    scope :internal_order_by_viewers, -> {
      joins("LEFT JOIN jobseeker_profile_views ON jobseeker_profile_views.jobseeker_id = final_jobseekers.f_j_id")
          .group("final_jobseekers.f_j_id").order("COUNT(jobseeker_profile_views.id) DESC")
    }

    scope :order_by_matching_percentage, -> {
      order("matching_percentage DESC")
    }

    scope :order_by_created_at, -> {
      order("created_at DESC")
    }


    # This method to set matching percentage for Job
    def self.add_matching_percentage jobseeker, job
      Jobseeker.calculate_matching_percentage(job, {id_in: [jobseeker.id, -1]}, 0, 100, "matching_percentage").first
    end
  end
end