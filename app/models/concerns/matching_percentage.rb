require 'active_support/concern'

module MatchingPercentage
  extend ActiveSupport::Concern

  included do

    include MatchingPercentageAttributes
    ATTR_WEIGHT = MatchingPercentageAttributes::ATTR_WEIGHT

    scope :select_order_params, -> {
      select("jobs.*, jobs.id AS m_id")
    }

    scope :country_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN country_id IS NOT NULL AND country_id != 0 AND country_id =#{jobseeker.user.country_id || -1} THEN #{ATTR_WEIGHT[:country]} ELSE 0 END AS country_percentage")
    }

    scope :city_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN city_id IS NOT NULL AND city_id != 0 AND city_id =#{jobseeker.user.city_id || -1} THEN #{ATTR_WEIGHT[:city]} ELSE 0 END AS city_percentage")
    }

    scope :sector_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN sector_id IS NOT NULL AND sector_id != 0 AND sector_id =#{jobseeker.sector_id || -1} THEN #{ATTR_WEIGHT[:sector]} ELSE 0 END AS sector_percentage")
    }

    scope :functional_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN functional_area_id IS NOT NULL AND functional_area_id != 0 AND functional_area_id =#{jobseeker.functional_area_id || -1} THEN #{ATTR_WEIGHT[:functional]} ELSE 0 END AS functional_percentage")
    }

    # TODO: if one of positions has character \' it will make an issue (improve solution latter)
    scope :position_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN (jobs.title IN (#{jobseeker.positions.map{|s| "'#{s.gsub("'", '')}'"}.join(',')})) THEN #{ATTR_WEIGHT[:position]} ELSE 0 END AS position_percentage")
    }

    scope :years_experience_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN #{jobseeker.years_of_experience || 0} BETWEEN experience_from AND  experience_to THEN #{ATTR_WEIGHT[:years_experience]} ELSE 0 END AS years_experience_percentage")
    }

    scope :job_experience_level_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN job_experience_level_id=#{jobseeker.job_experience_level_id || 0} THEN #{ATTR_WEIGHT[:job_experience_level]} ELSE 0 END AS job_experience_level_percentage")
    }

    scope :job_education_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN job_education_id=#{jobseeker.job_education_id || 0} THEN #{ATTR_WEIGHT[:job_education]} ELSE 0 END AS job_education_percentage")
    }

    scope :expected_salary_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN salary_range_id IN #{jobseeker.expected_salary_range_ids} THEN #{ATTR_WEIGHT[:expected_salary]} ELSE 0 END AS expected_salary_percentage")
    }

    scope :job_type_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN job_type_id=#{jobseeker.job_type_id || 0} THEN #{ATTR_WEIGHT[:job_type]} ELSE 0 END AS job_type_percentage")
    }

    scope :skills_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN jobs.id IN (#{jobseeker.job_ids_has_common_skills.join(',')}) THEN #{ATTR_WEIGHT[:skills]} ELSE 0 END AS skills_percentage")
    }

    scope :nationality_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN jobs.id IN (#{jobseeker.job_ids_in_same_geo_countries.join(',')}) THEN #{ATTR_WEIGHT[:nationality]} ELSE 0 END AS nationality_percentage")
    }

    scope :age_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN age_group_id IS NULL OR age_group_id IN (#{jobseeker.age_group_ids.join(',')}) THEN #{ATTR_WEIGHT[:age]} ELSE 0 END AS age_percentage")
    }

    scope :gender_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN gender IS NULL OR gender=#{jobseeker.gender} THEN #{ATTR_WEIGHT[:gender]} ELSE 0 END AS gender_percentage")
    }

    scope :marital_status_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN jobs.marital_status IS NULL OR jobs.marital_status = 'any' OR jobs.marital_status = '#{jobseeker.marital_status || ""}' THEN #{ATTR_WEIGHT[:marital_status]} ELSE 0 END AS marital_status_percentage")
    }

    scope :visa_status_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN jobs.visa_status_id IS NULL OR jobs.visa_status_id = '#{jobseeker.visa_status_id || 0}' THEN #{ATTR_WEIGHT[:visa_status]} ELSE 0 END AS visa_status_percentage")
    }

    scope :driving_license_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN (jobs.license_required IS FALSE OR jobs.license_required IS NULL) OR (jobs.license_required IS TRUE AND #{jobseeker.driving_license_country_id || 'NULL'} IS NOT NULL) THEN #{ATTR_WEIGHT[:driving_license]} ELSE 0 END AS driving_license_percentage")
    }

    # TODO: Update Languages when update tables
    scope :languages_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN jobs.id IN (#{jobseeker.job_ids_has_common_languages.join(',')}) THEN #{ATTR_WEIGHT[:languages]} ELSE 0 END AS languages_percentage")
    }

    scope :join_date_percentage, -> (jobseeker) {
      #select("jobs.*, CASE WHEN  join_date >= '#{jobseeker.join_date || 0}'::date THEN #{ATTR_WEIGHT[:join_date]} ELSE 0 END AS join_date_percentage")
      select("jobs.*, CASE WHEN  1=1 THEN #{ATTR_WEIGHT[:join_date]} ELSE 0 END AS join_date_percentage")
    }

    scope :certificates_percentage, -> (jobseeker) {
      select("jobs.*, CASE WHEN jobs.id IN (#{jobseeker.job_ids_has_common_certificates.join(',')}) THEN #{ATTR_WEIGHT[:certificates]} ELSE 0 END AS certificates_percentage")
    }

    scope :error_percentage, -> (jobseeker) {
      select("jobs.*,  -1 + (3 * CASE WHEN ((CASE WHEN ((country_id IS NOT NULL AND country_id != 0 AND country_id =#{jobseeker.user.country_id || -1}) OR (city_id IS NOT NULL AND city_id != 0 AND city_id =#{jobseeker.user.city_id || -1})) THEN 1 ELSE 0 END) + (CASE WHEN (sector_id IS NOT NULL AND sector_id != 0 AND sector_id =#{jobseeker.sector_id || -1}) THEN 1 ELSE 0 END) + (CASE WHEN (functional_area_id =#{jobseeker.functional_area_id || 0}) THEN 1 ELSE 0 END) + (CASE WHEN (jobs.id IN (#{jobseeker.job_ids_in_same_geo_group.join(',')})) THEN 1 ELSE 0 END) + (CASE WHEN (#{jobseeker.years_of_experience || 0} BETWEEN experience_from AND  experience_to) THEN 1 ELSE 0 END) + (CASE WHEN (jobs.title IN (#{jobseeker.positions.map{|s| "'#{s.gsub("'", '')}'"}.join(',')})) THEN 1 ELSE 0 END) - 1 ) > 0 THEN ((CASE WHEN ((country_id IS NOT NULL AND country_id != 0 AND country_id =#{jobseeker.user.country_id || -1}) OR (city_id IS NOT NULL AND city_id != 0 AND city_id =#{jobseeker.user.city_id || -1})) THEN 1 ELSE 0 END) + (CASE WHEN (sector_id IS NOT NULL AND sector_id != 0 AND sector_id =#{jobseeker.sector_id || -1}) THEN 1 ELSE 0 END) + (CASE WHEN (functional_area_id =#{jobseeker.functional_area_id || 0}) THEN 1 ELSE 0 END) + (CASE WHEN (jobs.id IN (#{jobseeker.job_ids_in_same_geo_group.join(',')})) THEN 1 ELSE 0 END) + (CASE WHEN (#{jobseeker.years_of_experience || 0} BETWEEN experience_from AND  experience_to) THEN 1 ELSE 0 END) + (CASE WHEN (jobs.title IN (#{jobseeker.positions.map{|s| "'#{s.gsub("'", '')}'"}.join(',')})) THEN 1 ELSE 0 END) - 1 ) ELSE 0 END) AS error_percentage")
    }

    scope :all_percentage, -> (jobseeker, fileter_params={}, order_by="id") {
      ATTR_WEIGHT.keys.inject(Job) {|res, key| res.send *"#{key.to_s}_percentage", jobseeker}.ransack(fileter_params).result(distinct: true)
    }

    scope :calculate_matching_percentage, -> (jobseeker, fileter_params = {}, order_by="") {
      if order_by == "matching_percentage"
        select("final_jobs.*, final_jobs.f_j_id, final_jobs.matching_percentage")
            .from(select("matched_jobs.*, matched_jobs.m_id AS f_j_id, (#{ATTR_WEIGHT.keys.map{|s| "matched_jobs.#{s.to_s}_percentage"} * ' + '}) AS matching_percentage")
                      .from(Job.select_order_params.all_percentage(jobseeker, fileter_params), :matched_jobs), :final_jobs)
            .order("final_jobs.matching_percentage DESC, final_jobs.f_j_id DESC")
      else
        select("final_jobs.*, final_jobs.f_j_id, final_jobs.matching_percentage")
            .from(select("matched_jobs.*, matched_jobs.m_id AS f_j_id, (#{ATTR_WEIGHT.keys.map{|s| "matched_jobs.#{s.to_s}_percentage"} * ' + '}) AS matching_percentage")
                      .from(Job.select_order_params.all_percentage(jobseeker, fileter_params, order_by), :matched_jobs), :final_jobs)
            .order("final_jobs.f_j_id DESC")
      end
    }

    scope :order_by_matching_percentage, -> {
      order("matching_percentage DESC")
    }

    scope :order_by_created_at, -> {
      order("created_at DESC")
    }

    scope :suggested_jobs, -> (jobseeker, order_by="", fileter_params={}) {
      Job.calculate_matching_percentage(jobseeker, fileter_params, order_by).where("final_jobs.matching_percentage >= 60")
    }

    # This method to set matching percentage for Job
    def self.add_matching_percentage jobseeker, job
      Job.calculate_matching_percentage(jobseeker, {id_in: [job.id]})[0]
    end

    # This method is not used
    def self.order_by_matching_percentage_demo(jobseeker, filter_params = {})

      # override all nil values to zero to avoid sql exceptions
      jobseeker.attributes.map { |attr_name, attr_value| jobseeker[attr_name] = 0 if attr_value.nil? }

      filter_query = self.ransack(filter_params).result(distinct: true).to_sql

      query = <<-SQL

      SELECT matched_jobs.*,
             matched_jobs.country_percentage +
             matched_jobs.city_percentage +
             matched_jobs.sector_percentage +
             matched_jobs.functional_percentage +
             matched_jobs.position_percentage +
             matched_jobs.years_of_experience_percentage +
             matched_jobs.experience_level_percentage +
             matched_jobs.job_education_percentage +
             matched_jobs.expected_salary_percentage +
             matched_jobs.job_type_percentage +
             matched_jobs.skills_percentage +
             matched_jobs.nationality_percentage +
             matched_jobs.age_percentage +
             matched_jobs.gender_percentage +
             matched_jobs.marital_status_percentage +
             matched_jobs.driving_percentage +
             matched_jobs.languages_percentage +
             matched_jobs.join_date_percentage +
             matched_jobs.certificates_percentage +
             matched_jobs.error_percentage
             as matching_percentage from (

        SELECT jobs.id,
               functional_area_id,
               sector_id,
               job_education_id,
               country_id,
               city_id,
               experience_from,
               experience_to,
               job_experience_level_id,
               job_education_id,
               job_type_id,
               title,
               company_id,
               age_group_id,
               gender,
               marital_status,
               visa_status_id,
               license_required,
               languages,
               join_date, start_date, views_count,

          CASE
            WHEN country_id =#{jobseeker.user.country_id || 0} THEN #{ATTR_WEIGHT[:country_id]} ELSE 0
          END
          AS country_percentage,

          CASE
            WHEN city_id =#{jobseeker.user.city_id || 0} THEN #{ATTR_WEIGHT[:city_id]} ELSE 0
          END
          AS city_percentage,

          CASE
            WHEN sector_id =#{jobseeker.sector_id || 0} THEN #{ATTR_WEIGHT[:sector_id]} ELSE 0
          END
          AS sector_percentage,

          CASE
            WHEN functional_area_id =#{jobseeker.functional_area_id || 0} THEN #{ATTR_WEIGHT[:functional_area_id]} ELSE 0
          END
          AS functional_percentage,

          CASE
            WHEN title ='#{jobseeker.current_position}' THEN #{ATTR_WEIGHT[:position]} ELSE 0
          END
          AS position_percentage,

          CASE
            WHEN #{jobseeker.years_of_experience} BETWEEN experience_from AND  experience_to THEN #{ATTR_WEIGHT[:years_of_experience]} ELSE 0
          END
          AS years_of_experience_percentage,

          CASE
           WHEN job_experience_level_id=#{jobseeker.job_experience_level_id || 0} THEN #{ATTR_WEIGHT[:job_experience_level_id]} ELSE 0
          END
          AS experience_level_percentage,

          CASE
           WHEN job_education_id=#{jobseeker.job_education_id || 0} THEN #{ATTR_WEIGHT[:job_education_id]} ELSE 0
          END
          AS job_education_percentage,

          CASE
            WHEN salary_range_id=#{jobseeker.expected_salary_range.try(:id) || 0} THEN #{ATTR_WEIGHT[:expected_salary]} ELSE 0
          END
          AS expected_salary_percentage,

          CASE
           WHEN job_type_id=#{jobseeker.job_type_id || 0} THEN #{ATTR_WEIGHT[:job_type_id]} ELSE 0
          END
          AS job_type_percentage,

          CASE
           WHEN jobs.id IN (#{jobseeker.job_ids_has_common_skills.join(',')}) THEN #{ATTR_WEIGHT[:skill_ids]} ELSE 0
          END
          AS skills_percentage,

          CASE
           WHEN jobs.id IN (#{jobseeker.job_ids_in_same_geo_group.join(',')}) THEN #{ATTR_WEIGHT[:nationality_id]} ELSE 0
          END
          AS nationality_percentage,

          CASE
           WHEN age_group_id IS NULL OR age_group_id=#{jobseeker.age_group.try(:id) || 0} THEN #{ATTR_WEIGHT[:age]} ELSE 0
          END
          AS age_percentage,

          CASE
           WHEN gender IS NULL OR gender=#{jobseeker.gender || 0} THEN #{ATTR_WEIGHT[:gender]} ELSE 0
          END AS gender_percentage,

          CASE
           WHEN marital_status IS NULL OR marital_status='#{jobseeker.marital_status}' THEN #{ATTR_WEIGHT[:marital_status]} ELSE 0
          END AS marital_status_percentage,

          CASE
           WHEN visa_status_id IS NULL OR visa_status_id='#{jobseeker.visa_status_id}' THEN #{ATTR_WEIGHT[:visa_status_id]} ELSE 0
          END AS visa_status_percentage,

          CASE
           WHEN license_required IS NULL OR (license_required IS TRUE AND #{jobseeker.has_driving_license} IS TRUE) THEN #{ATTR_WEIGHT[:driving_license]} ELSE 0
          END AS driving_percentage,

          CASE
           WHEN languages='#{jobseeker.languages}' THEN #{ATTR_WEIGHT[:languages]} ELSE 0
          END AS languages_percentage,

          CASE
           WHEN join_date='#{jobseeker.join_date}'::date THEN #{ATTR_WEIGHT[:notice_period]} ELSE 0
          END AS join_date_percentage,

          CASE
            WHEN jobs.id IN (#{jobseeker.job_ids_has_common_certificates.join(',')}) THEN #{ATTR_WEIGHT[:certificate_ids]} ELSE 0
          END
          AS certificates_percentage,

          CASE
            WHEN 1=1 THEN
              CASE
                WHEN (city_id = #{jobseeker.user.city_id}) THEN 1 ELSE 0
              END +
              CASE
                WHEN (sector_id =#{jobseeker.sector_id}) THEN 1 ELSE 0
              END +
              CASE
                WHEN (functional_area_id =#{jobseeker.functional_area_id}) THEN 1 ELSE 0
              END +
              CASE
                WHEN (jobs.id IN (#{jobseeker.job_ids_in_same_geo_group.join(',')})) THEN 1 ELSE 0
              END
            ELSE 0
          END AS error_percentage


          FROM  jobs) matched_jobs
          ORDER BY matching_percentage DESC
        SQL
        self.find_by_sql("#{filter_query}")
    end
  end
end