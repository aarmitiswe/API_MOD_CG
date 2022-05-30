require 'smarter_csv'
require 'date'


############## Helper Classes ##################
class NationalityConverter
  def self.convert(value)
    return Country.find_by_name(value).try(:id) unless value.nil?
  end
end

class DateTimeConverter
  def self.convert(value)
    unless value.nil?
      if value.include?('.')
        return DateTime.strptime(value, '%Y-%m-%d %H:%M:%S.%L')
      else
        return DateTime.strptime(value, '%Y-%m-%d %H:%M:%S')
      end
    end
  end
end

class BooleanConverter
  def self.convert(value)
    if value == 't'
      return true
    else
      return false
    end
  end
end

class UserTypeConverter
  @@user_types_list = %w(jobseeker company_owner company_admin company_user)

  def self.convert(value)
    return @@user_types_list[value - 1] unless value.nil?
  end
end

class UserDetailsFieldsConverter
  def self.convert(value)
    fields = {
        1  => :current_city_id,
        6  => :mobile_phone,
        7  => :home_phone,
        11 => :zip,
        13 => :website,
        23 => :languages,
        32 => :focus,
        33 => :summary,
        35 => :company_summary,
        36 => :address_line1,
        37 => :address_line2,
        38 => :no_of_employees,
        39 => :last_year_revenues,
        40 => :company_type,
        41 => :company_classification,
        42 => :google_plus_page_url,
        43 => :linkedin_page_url,
        44 => :facebook_page_url,
        45 => :twitter_page_url,
        46 => :profile_image_file,
        47 => :fax,
        48 => :company_industry,
        50 => :job_role_id,
        51 => :sector_id,
        52 => :functional_area_id,
        53 => :job_experience_level_id,
        54 => :years_of_experience,
        55 => :job_experience_months,
        56 => :job_type_id,
        57 => :current_salary,
        58 => :expected_salary,
        59 => :job_education_id,
        60 => :job_category_id,
        61 => :nationality_id,
        62 => :company_email,
        63 => :contact_person,
        64 => :profile_video,
        65 => :profile_video_image,
        # 66 => :temp_user_name
    }
    return fields[value]
  end
end

class DateConverter
  def self.convert(value)
    return Date.strptime(value, '%Y-%m-%d') unless value.nil?
  end
end


############## Helper Methods ##################

## Extract data records from CSV
def extract_data(table_name, options={})
  file_path = Rails.root.join('csv_files', "public.#{table_name}.csv")
  ##TODO handle exceptions
  SmarterCSV.process(file_path, options)
end

## Extract external data records from CSV
def extract_external_data(file_name, options={})
  file_path = Rails.root.join('external_csv', "#{file_name}.csv")
  ##TODO handle exceptions
  SmarterCSV.process(file_path, options)
end

## Map jobseeker id
def get_jobseeker_id(user_id)
  user = User.find_by_id(user_id)
  unless user.nil?
    return user.jobseeker.id unless user.jobseeker.nil?
  end
end

## work around to fix auto increment issue after insert explicit
def set_max_ids(table_name)
  query = "SELECT setval('#{table_name}_id_seq', (SELECT MAX(id) from #{table_name}))"
  ActiveRecord::Base.connection.execute(query)
end

## reset table ids counter
def reset_table_ids(table_name)
  query = "ALTER SEQUENCE #{table_name}_id_seq RESTART WITH 1"
  ActiveRecord::Base.connection.execute(query)
end