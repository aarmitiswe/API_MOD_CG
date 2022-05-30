module AdjustSearchParamsHelper
  def update_search_params_jobseekers

    return if params[:q].nil?

    # cur_sal_eq is id in SalaryRange Table
    if params[:q][:cur_sal_in].present?
      current_salary_ranges = SalaryRange.where(id: params[:q][:cur_sal_in])

      params[:q][:current_salary_gteq] = current_salary_ranges.minimum("salary_from")
      params[:q][:current_salary_lteq] = current_salary_ranges.maximum("salary_to")

      params[:q].delete(:cur_sal_in)
    end
    # exp_sal_eq is id in SalaryRange Table
    if params[:q][:exp_sal_in].present?
      exp_salary_ranges = SalaryRange.where(id: params[:q][:exp_sal_in])

      params[:q][:expected_salary_gteq] = exp_salary_ranges.minimum("salary_from")
      params[:q][:expected_salary_lteq] = exp_salary_ranges.maximum("salary_to")

      params[:q].delete(:exp_sal_in)
    end

    # act_lteq 0 day, 1 week, 2 week, 1 month, 2 month, 3 month, 6 month, 12 month
    if params[:q][:act_lteq].present?
      num = params[:q][:act_lteq].split(" ")[0].to_i
      unit = params[:q][:act_lteq].split(" ")[1]
      params[:q][:user_last_sign_in_at_gteq] = Date.today - num.send(unit)

      params[:q].delete(:act_lteq)
    end

    # exp_eq id in ExperienceRange Table
    if params[:q][:exp_in].present?
      experience_ranges = ExperienceRange.where(id: params[:q][:exp_in])

      params[:q][:g] ||= {}
      params[:q][:g]["0"] ||= {}
      params[:q][:g]["0"][:g] ||= {}
      params[:q][:g]["0"][:m] ||= 'or'
      experience_ranges.each_with_index do |exp, index|
        params[:q][:g]["0"][:g]["#{index}"] = {years_of_experience_gteq: exp.experience_from, years_of_experience_lteq: exp.experience_to}
      end
      # params[:q][:years_of_experience_gteq] = experience_ranges.minimum("experience_from")
      # params[:q][:years_of_experience_lteq] = experience_ranges.maximum("experience_to")

      params[:q].delete(:exp_in)
    end

    # age_eq id in AgeGroup
    if params[:q][:age_in].present?
      age_groups = AgeGroup.where(id: params[:q][:age_in])

      params[:q][:g] ||= {}
      current_index = params[:q][:g]["0"].nil? ? "0" : "1"
      params[:q][:g][current_index] ||= {}
      params[:q][:g][current_index][:g] ||= {}
      params[:q][:g][current_index][:m] ||= 'or'
      age_groups.each_with_index do |age_group, index|
        params[:q][:g][current_index][:g]["#{index}"] = {user_birthday_gteq: Date.today - age_group.max_age.year,
                                                         user_birthday_lteq: Date.today - age_group.min_age.year}
      end

      # params[:q][:user_birthday_gteq] = Date.today - age_groups.maximum("max_age").year
      # params[:q][:user_birthday_lteq] = Date.today - age_groups.minimum("min_age").year

      params[:q].delete(:age_in)
    end

    # if params[:q][:la_in].present?
    #   params[:q][:languages_cont] = params[:q][:la_in].join(',')
    #   params[:q].delete(:la_in)
    # end
  end

  def update_text_params
    search_by_text = {}
    page = (params[:page] || 1).to_i * 10
    start = page - 10
    if params[:q] && params[:q][:text] && params[:q][:matching]
      if params[:q][:matching] == "any"
        # search_by_text[:user_full_name_has_any_word] = params[:q][:text]
        # search_by_text[:summary_has_any_word] = params[:q][:text]
        # search_by_text[:sector_name_has_any_word] = params[:q][:text]
        # search_by_text[:functional_area_area_has_any_word] = params[:q][:text]
        # search_by_text[:skills_name_has_any_word] = params[:q][:text]
        # search_by_text[:jobseeker_experiences_position_or_jobseeker_experiences_description_or_jobseeker_experiences_company_name_has_any_word] = params[:q][:text]
        # search_by_text[:jobseeker_experiences_content_has_any_word] = params[:q][:text]
        # search_by_text[:jobseeker_certificates_name_or_jobseeker_certificates_institute_has_any_word] = params[:q][:text]
        # search_by_text[:jobseeker_educations_school_has_any_word] = params[:q][:text]
        q_part = params[:q][:text].split(" ").map{|s| "jobseeker_content.keywords ilike '%#{s}%'" }.join(" OR ")
        query = <<-SQL
          select distinct jobseeker_content.id from jobseeker_content where #{q_part};
        SQL
        jobseeker_ids = Jobseeker.find_by_sql("#{query}").map(&:id) << -1
        search_by_text[:id_in] = jobseeker_ids

      elsif params[:q][:matching] == "all"
        # search_by_text[:user_full_name_cont_all] = params[:q][:text].split(" ")
        # search_by_text[:summary__cont_all] = params[:q][:text].split(" ")
        # search_by_text[:sector_name_cont_all] = params[:q][:text]
        # search_by_text[:functional_area_area_cont_all] = params[:q][:text]
        # search_by_text[:skills_name_cont_all] = params[:q][:text].split(" ")
        # search_by_text[:jobseeker_experiences_position_or_jobseeker_experiences_description_or_jobseeker_experiences_company_name_cont_all] = params[:q][:text]
        # search_by_text[:jobseeker_experiences_content_cont_all] = params[:q][:text].split(" ")
        # search_by_text[:jobseeker_certificates_name_or_jobseeker_certificates_institute_cont_all] = params[:q][:text]
        # search_by_text[:jobseeker_educations_school_cont_all] = params[:q][:text]

        q_part = params[:q][:text].split(" ").map{|s| "jobseeker_content.keywords ilike '%#{s}%'" }.join(" AND ")
        query = <<-SQL
          select distinct jobseeker_content.id from jobseeker_content where #{q_part};
        SQL
        jobseeker_ids = Jobseeker.find_by_sql("#{query}").map(&:id) << -1
        search_by_text[:id_in] = jobseeker_ids
      elsif params[:q][:matching] == "exact"
        # search_by_text[:user_full_name_cont] = params[:q][:text]
        # search_by_text[:summary_cont] = params[:q][:text]
        # search_by_text[:sector_name_cont] = params[:q][:text]
        # search_by_text[:functional_area_area_cont] = params[:q][:text]
        # search_by_text[:skills_name_cont] = params[:q][:text]
        # search_by_text[:jobseeker_experiences_position_or_jobseeker_experiences_description_or_jobseeker_experiences_company_name_cont] = params[:q][:text]
        # search_by_text[:jobseeker_experiences_content_cont] = params[:q][:text]
        # search_by_text[:jobseeker_certificates_name_or_jobseeker_certificates_institute_cont] = params[:q][:text]
        # search_by_text[:jobseeker_educations_school_cont] = params[:q][:text]
        q_part = "'%#{params[:q][:text]}%'"
        query = <<-SQL
          select distinct jobseeker_content.id from jobseeker_content where jobseeker_content.keywords ilike #{q_part};
        SQL
        jobseeker_ids = Jobseeker.find_by_sql("#{query}").map(&:id) << -1
        search_by_text[:id_in] = jobseeker_ids
      end
      search_by_text[:m] = 'or'
      params[:q].delete(:text)
      params[:q].delete(:matching)

      search_by_attrs =  params[:q].dup unless params[:q].blank?
      params[:q][:g] ||= {}
      params[:q] = {g: { "#{params[:q][:g].keys.count}" => search_by_text }}

      unless search_by_attrs.blank?
        params[:q][:g]["#{params[:q][:g].keys.count}"] = search_by_attrs.merge!({m: 'and'})
      end
    end
  end
end