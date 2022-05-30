class FilterWithApplicantsCountSerializer < ActiveModel::Serializer
  attributes :id, :count_applicants_by_country, :count_applicants_by_city, :count_applicants_by_sector,
             :count_applicants_by_functional_area, :count_applicants_by_job_education, :count_applicants_by_nationality,
             :count_applicants_by_visa_status, :count_applicants_by_marital_status, :count_applicants_by_job_type,
             :count_applicants_by_gender, :count_applicants_by_language, :count_applicants_by_notice_period,
             :count_applicants_by_experience_range, :count_applicants_by_current_salary_range,
             :count_applicants_by_expected_salary_range, :count_applicants_by_age_range, :count_applicants_by_jobseeker_type,
             :count_applicants_by_master_grade, :count_applicants_by_bachelor_grade, :count_applicants_by_ielts_score,
             :count_applicants_by_toefl_score


  def count_applicants_by_country
    # applicants_countries_with_names = Country.where(id: User.where(id: object.applicants.pluck(:user_id)).pluck(:country_id)).reduce({}) do |hash, country|
    #   hash[country.id] = serialization_options[:ar] ? country.try(:ar_name) : country.try(:name)
    #   hash
    # end

    country_id_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                            .get_applications_of_job_group_by_user_country(object)
    applicants_countries_with_names = Country.where(id: country_id_with_applicants_count.keys).reduce({}) do |hash, country|
      hash[country.id] = serialization_options[:ar] ? country.try(:ar_name) : country.try(:name)
      hash
    end

    country_id_with_applicants_count.map do |country_id, applicants_count|
      {id: country_id, name: applicants_countries_with_names[country_id], applicants_count: applicants_count}
    end
  end

  def count_applicants_by_city
    # applicants_cities_with_names = City.where(id: User.where(id: object.applicants.pluck(:user_id)).pluck(:city_id)).reduce({}) do |hash, city|
    #   hash[city.id] = serialization_options[:ar] ? city.try(:ar_name) : city.try(:name)
    #   hash
    # end

    city_id_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                         .get_applications_of_job_group_by_user_city(object)
    applicants_cities_with_names = City.where(id: city_id_with_applicants_count.keys).reduce({}) do |hash, city|
      hash[city.id || 'Null'] = {name: (serialization_options[:ar] ? city.try(:ar_name) : city.try(:name)), country_id: city.country_id}
      hash
    end
    applicants_cities_with_names['Null'] = {name: 'Null', country_id: nil}
    city_id_with_applicants_count.map do |city_id, applicants_count|
      city_id ||= 'Null'
      {id: city_id, name: applicants_cities_with_names[city_id][:name], applicants_count: applicants_count, country_id: applicants_cities_with_names[city_id][:country_id]}
    end
  end

  def count_applicants_by_sector

    sector_id_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                           .get_applications_of_job_group_by_sector(object)
    applicants_sectors_with_names = Sector.where(id: sector_id_with_applicants_count.keys).reduce({}) do |hash, sector|
      hash[sector.id] = serialization_options[:ar] ? sector.try(:ar_name) : sector.try(:name)
      hash
    end

    sector_id_with_applicants_count.map do |sector_id, applicants_count|
      {id: sector_id, name: applicants_sectors_with_names[sector_id], applicants_count: applicants_count}
    end
  end

  def count_applicants_by_functional_area

    functional_area_id_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                                    .get_applications_of_job_group_by_functional_area(object)
    applicants_functional_areas_with_names = FunctionalArea.where(id: functional_area_id_with_applicants_count.keys).reduce({}) do |hash, func_area|
      hash[func_area.id] = serialization_options[:ar] ? func_area.try(:ar_area) : func_area.try(:area)
      hash
    end

    functional_area_id_with_applicants_count.map do |func_area_id, applicants_count|
      {id: func_area_id, name: applicants_functional_areas_with_names[func_area_id], applicants_count: applicants_count}
    end
  end

  def count_applicants_by_job_education

    job_education_id_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                                  .get_applications_of_job_group_by_job_eduction(object)
    applicants_job_educations_with_names = JobEducation.where(id: job_education_id_with_applicants_count.keys).reduce({}) do |hash, job_education|
      hash[job_education.id] = serialization_options[:ar] ? job_education.try(:ar_level) : job_education.try(:level)
      hash
    end

    job_education_id_with_applicants_count.map do |job_education_id, applicants_count|
      {id: job_education_id, name: applicants_job_educations_with_names[job_education_id], applicants_count: applicants_count}
    end
  end

  def count_applicants_by_nationality

    nationality_id_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                                .get_applications_of_job_group_by_nationality(object)
    applicants_nationalities_with_names = Country.where(id: nationality_id_with_applicants_count.keys).reduce({}) do |hash, country|
      hash[country.id] = serialization_options[:ar] ? country.try(:ar_name) : country.try(:name)
      hash
    end

    nationality_id_with_applicants_count.map do |country_id, applicants_count|
      {id: country_id, name: applicants_nationalities_with_names[country_id], applicants_count: applicants_count}
    end
  end

  def count_applicants_by_visa_status

    visa_status_id_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                                .get_applications_of_job_group_by_visa_status(object)
    applicants_visa_statuses_with_names = VisaStatus.where(id: visa_status_id_with_applicants_count.keys).reduce({}) do |hash, visa_status|
      hash[visa_status.id] = serialization_options[:ar] ? visa_status.try(:ar_name) : visa_status.try(:name)
      hash
    end

    visa_status_id_with_applicants_count.map do |visa_status_id, applicants_count|
      {id: visa_status_id, name: applicants_visa_statuses_with_names[visa_status_id], applicants_count: applicants_count}
    end
  end

  def count_applicants_by_marital_status

    marital_status_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                                .get_applications_of_job_group_by_marital_status(object)

    marital_status_with_applicants_count.map do |marital_status, applicants_count|
      {marital_status: marital_status, applicants_count: applicants_count}
    end
  end


  def count_applicants_by_jobseeker_type

    jobseeker_type_with_applicants_count =  JobApplication.get_applications_of_job_group_by_jobseeker_type(object)

    jobseeker_type_with_applicants_count.map do |jobseeker_type, applicants_count|
      {jobseeker_type: jobseeker_type, applicants_count: applicants_count}
    end
  end

  def count_applicants_by_job_type

    job_type_id_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                             .get_applications_of_job_group_by_job_type(object)
    applicants_job_types_with_names = JobType.where(id: job_type_id_with_applicants_count.keys).reduce({}) do |hash, job_type|
      hash[job_type.id] = serialization_options[:ar] ? job_type.try(:ar_name) : job_type.try(:name)
      hash
    end

    job_type_id_with_applicants_count.map do |job_type_id, applicants_count|
      {id: job_type_id, name: applicants_job_types_with_names[job_type_id], applicants_count: applicants_count}
    end
  end

  def count_applicants_by_gender

    gender_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                        .get_applications_of_job_group_by_gender(object)

    gender_with_applicants_count.map do |gender, applicants_count|
      {gender: gender, applicants_count: applicants_count}
    end
  end

  def count_applicants_by_language

    language_id_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                             .get_applications_of_job_group_by_language(object)
    applicants_languages_with_names = Language.where(id: language_id_with_applicants_count.keys).reduce({}) do |hash, language|
      hash[language.id] = serialization_options[:ar] ? language.try(:ar_name) : language.try(:name)
      hash
    end

    language_id_with_applicants_count.map do |language_id, applicants_count|
      {id: language_id, name: applicants_languages_with_names[language_id], applicants_count: applicants_count}
    end
  end

  def count_applicants_by_notice_period

    notice_period_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                               .get_applications_of_job_group_by_notice_period(object)

    notice_period_with_applicants_count.map do |notice_period, applicants_count|
      {notice_period: notice_period, applicants_count: applicants_count}
    end
  end

  def count_applicants_by_experience_range

    experience_range_id_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                                     .get_applications_of_job_group_by_experience_range(object)
    applicants_experience_ranges = ExperienceRange.where(id: experience_range_id_with_applicants_count.keys).reduce({}) do |hash, experience_range|
      hash[experience_range.id] = "#{experience_range.experience_from} - #{experience_range.experience_to}"
      hash
    end

    experience_range_id_with_applicants_count.map do |experience_range_id, applicants_count|
      {id: experience_range_id, range: applicants_experience_ranges[experience_range_id], applicants_count: applicants_count}
    end
  end

  def count_applicants_by_current_salary_range

    current_salary_range_id_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                                         .get_applications_of_job_group_by_current_salary(object)
    applicants_current_salary_ranges = SalaryRange.where(id: current_salary_range_id_with_applicants_count.keys).reduce({}) do |hash, current_salary_range|
      hash[current_salary_range.id] = "#{current_salary_range.salary_from} - #{current_salary_range.salary_to}"
      hash
    end

    current_salary_range_id_with_applicants_count.map do |current_salary_range_id, applicants_count|
      {id: current_salary_range_id, range: applicants_current_salary_ranges[current_salary_range_id], applicants_count: applicants_count}
    end
  end

  def count_applicants_by_expected_salary_range

    expected_salary_range_id_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                                          .get_applications_of_job_group_by_expected_salary(object)
    applicants_expected_salary_ranges = SalaryRange.where(id: expected_salary_range_id_with_applicants_count.keys).reduce({}) do |hash, expected_salary_range|
      hash[expected_salary_range.id] = "#{expected_salary_range.salary_from} - #{expected_salary_range.salary_to}"
      hash
    end

    expected_salary_range_id_with_applicants_count.map do |expected_salary_range_id, applicants_count|
      {id: expected_salary_range_id, range: applicants_expected_salary_ranges[expected_salary_range_id], applicants_count: applicants_count}
    end
  end

  def count_applicants_by_age_range
    date_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                      .get_applications_of_job_group_by_age_group(object)
    # ToDo: Check with yakout why static Age range was used
    # age_range_with_applicants_count = {}
    #
    # date_with_applicants_count.each do |date_str, applicants_count|
    #   User::AGE_RANGES.each do |range|
    #     range_string = "#{range[:age_from]}-#{range[:age_to]}"
    #     age = ((Date.today - date_str.to_date).to_i / 365.0).ceil
    #     if age >= range[:age_from] && age <= range[:age_to]
    #       age_range_with_applicants_count[range_string] ||= 0
    #       age_range_with_applicants_count[range_string] += applicants_count
    #     end
    #   end
    # end
    #
    # age_range_with_applicants_count.map {|range, count| {range: range, applicants_count: count}}

    # TODo: Refactor code
    age_range_with_applicants_count = []
    AgeGroup.all.each do |range|
      date_with_applicants_count.each do |date_str, applicants_count|
        range_string = "#{range[:min_age]}-#{range[:max_age]}"
        age = ((Date.today - date_str.to_date).to_i / 365.0).floor
        range_match = false
        if age >= range[:min_age] && age <= range[:max_age]
          # Checking for Duplicates and suming it up
          age_range_with_applicants_count.each_with_index  do |sel_rang, rang_idex|
            if sel_rang[:range] == range_string
              age_range_with_applicants_count[rang_idex][:applicants_count] += applicants_count
              range_match = true
            end
          end
          if !range_match
            age_range_with_applicants_count.push({id: range.id, range: range_string, applicants_count: applicants_count})
          end
        end
      end
    end

    age_range_with_applicants_count


  end

  def count_applicants_by_master_grade
    master_degree_grade_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                                     .get_applications_of_job_group_by_master_degree_grade(object)
    master_degree_grade_with_applicants_count
  end

  def count_applicants_by_bachelor_grade
    bachelor_degree_grade_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                                       .get_applications_of_job_group_by_bachelor_degree_grade(object)
    bachelor_degree_grade_with_applicants_count
  end

  def count_applicants_by_ielts_score
    ielts_score_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                             .get_applications_of_job_group_by_ielts_score(object)
    ielts_score_with_applicants_count
  end


  def count_applicants_by_toefl_score
    toefl_score_with_applicants_count =  JobApplication.where(jobseeker_id: Jobseeker.ransack(serialization_options[:query_params]).result.pluck(:id))
                                             .get_applications_of_job_group_by_toefl_score(object)
    toefl_score_with_applicants_count
  end



  # def count_applicants_by_last_active
  #   last_active_with_applicants_count =  JobApplication.get_applications_of_job_group_by_last_active(object)
  #   last_active_with_applicants_count.keys.reduce({}) do |hash, day_string|
  #     period =  day_string.blank? ? "No Period" : (Date.today - day_string.to_date).to_i
  #     hash[job_type.id] = serialization_options[:ar] ? job_type.try(:ar_name) : job_type.try(:name)
  #     hash
  #   end
  # end


end