class CompanyJobApplicationsGroupedSerializer < ActiveModel::Serializer
delegate :current_user, to: :scope

  attributes :id, :job_applications_by_sector, :job_applications_by_country, :job_applications_by_nationality,
             :job_applications_by_age_group, :job_applications_by_education, :job_applications_by_gender



  def filtered_job_application_ids
    @job_application_ids ||= current_user.created_applications.where(job_id: object.jobs.not_graduate_program.ransack(serialization_options[:q]).result.map(&:id)).map(&:id)
    @job_application_ids
  end

  def job_applications_by_sector
    # grouped_hash = object.job_applications_by_sector
    grouped_hash = current_user.created_applications.where(id: filtered_job_application_ids).get_applications_of_company_group_by_sector(object)
    build_graph_json(grouped_hash, "Sector")
  end

  def job_applications_by_country
    # grouped_hash = object.job_applications_by_country
    grouped_hash = current_user.created_applications.where(id: filtered_job_application_ids).get_applications_of_company_group_by_country(object)
    build_graph_json(grouped_hash, "Country", 'iso')
  end

  def job_applications_by_nationality
    # grouped_hash = object.job_applications_by_nationality
    grouped_hash = current_user.created_applications.where(id: filtered_job_application_ids).get_applications_of_company_group_by_nationality(object)
    build_graph_json(grouped_hash, "Country")
  end

  def job_applications_by_age_group
    # year_count = object.job_applications_by_age_group
    year_count = current_user.created_applications.where(id: filtered_job_application_ids).get_applications_of_company_group_by_age_group(object)
    build_age_group_graph_json(year_count)
  end

  def job_applications_by_education
    # grouped_hash = object.job_applications_by_education
    grouped_hash = current_user.created_applications.where(id: filtered_job_application_ids).get_applications_of_company_group_by_education(object)
    build_graph_json(grouped_hash, "JobEducation")
  end

  def job_applications_by_gender
    # grouped_hash = object.job_applications_by_gender
    grouped_hash = current_user.created_applications.where(id: filtered_job_application_ids).get_applications_of_company_group_by_gender(object)
    grouped_hash.map{|key, val| {name: "#{User::GENDER[key || 0]}", percentage: (val.to_f / filtered_job_application_ids.count.to_f) * 100.0}}
  end



  protected
    def build_graph_json grouped_hash, table_name = nil, extra_column = nil
      total_sum = grouped_hash.values.sum
      sector_percentage_arr = []
      not_defined = serialization_options[:ar] && serialization_options[:ar] == 'true' ? "غير معرف" : "Undefined"
      if !table_name.blank?
        grouped_hash.each do |key, val|
          percentage = total_sum.zero? ? 0 : ((val.to_f / total_sum.to_f) * 100).round(1)
          sector_percentage_arr.push({
                                         name: (serialization_options[:ar] && serialization_options[:ar] == 'true' ? table_name.constantize.find_by_id(key).try(:ar_name) : table_name.constantize.find_by_id(key).try(:name)) || not_defined,
                                         percentage: percentage
                                     })
          if !extra_column.blank?
            sector_percentage_arr.last[extra_column] = table_name.constantize.find_by_id(key).try(extra_column) || "Undefined"
          end
        end
      else
        sector_percentage_arr = grouped_hash.map{ |key, val| {name: key, percentage: (total_sum.zero? ? 0 : ((val.to_f / total_sum.to_f) * 100).round(1))} }
      end
      sector_percentage_arr.sort! { |a,b| b[:percentage] <=> a[:percentage] }
    end


   def build_age_group_graph_json year_count
     grouped_hash = {}
     year_count.each do |year, count|
       age = (Time.now - year).to_i / (365 * 24 * 60 * 60)
       age_group = AgeGroup.where("min_age <= ? AND max_age >= ?", age, age).first
       next if age_group.nil?
       range_str = "#{age_group.min_age} - #{age_group.max_age}"
       grouped_hash[range_str] = grouped_hash[range_str].to_i + count
     end
     build_graph_json(grouped_hash)
   end




end