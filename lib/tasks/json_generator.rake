require 'aws-sdk'

def upload_json_to_s3 file_name, txt
  aws_obj = Aws::S3::Object.new(Rails.application.secrets['AWS_BUCKET'], "public_json/#{file_name}", {
      region: Rails.application.secrets['AWS_REGION'],
      secret_access_key: Rails.application.secrets['AWS_SECRET_ACCESS_KEY'],
      access_key_id: Rails.application.secrets['AWS_ACCESS_KEY_ID']
  })

  aws_obj.put({body: txt, acl:'public-read'})
  puts "Done JSON Upload to S3"
end

namespace :json_generator do
  desc 'Update Countries with Jobs Count JSON Daily General'
  task write_countries_with_count_jobs_general: :environment do
    countries = Country.order_by_jobs
    countries = countries | Country.where.not(id: countries.map(&:id))
    countries_json = {countries: countries.map{ |country| CountrySerializer.new(country).serializable_hash }}

    upload_json_to_s3 "countries.json", countries_json.to_json
  end


  desc 'Update Sectors with Jobs Count JSON Daily General'
  task write_sectors_with_count_jobs_general: :environment do
    sectors = Sector.order_by_jobs
    sectors = sectors | Sector.where.not(id: sectors.map(&:id))
    sectors_json = {sectors: sectors.map{ |sector| SectorSerializer.new(sector).serializable_hash }}

    upload_json_to_s3 "sectors.json", sectors_json.to_json
  end


  desc 'Update Cities with Jobs Count JSON Daily General'
  task write_cities_with_count_jobs_general: :environment do
    cities = City.order_by_jobs
    cities = cities | City.where.not(id: cities.map(&:id))
    cities_json = {cities: cities.map{ |city| CitySerializer.new(city).serializable_hash }}

    upload_json_to_s3 "cities.json", cities_json.to_json
  end


  desc 'Update Companies JSON Daily General'
  task write_companies_general: :environment do
    companies = Company.active.order_by_alphabetical
    companies_json = {
        companies: companies.map{ |company| CompanyAllSerializer.new(company).serializable_hash }
    }

    upload_json_to_s3 "companies.json", companies_json.to_json
  end

  desc "Update Sector with new values"
  task update_sectors: :environment do
    sectors_alpha_order = Sector.order_by_alphabetical
    sectors_alpha_order_json = {
      sectors: sectors_alpha_order.map{ |sector| SectorSerializer.new(sector).serializable_object }
    }

    upload_json_to_s3 "en/sectors_alpha.json", sectors_alpha_order_json.to_json

    sectors_alpha_ar_order_json = {
        sectors: sectors_alpha_order.map{ |sector| SectorSerializer.new(sector).serializable_object({ar: true}) }
    }

    upload_json_to_s3 "ar/sectors_alpha.json", sectors_alpha_ar_order_json.to_json

    sectors_jobs_order = Sector.order_by_jobs
    sectors_jobs_order_json = {
        sectors: sectors_jobs_order.map{ |sector| SectorSerializer.new(sector).serializable_object }
    }

    upload_json_to_s3 "en/sectors_jobs.json", sectors_jobs_order_json.to_json

    sectors_jobs_ar_order_json = {
        sectors: sectors_jobs_order.map{ |sector| SectorSerializer.new(sector).serializable_object }
    }

    upload_json_to_s3 "ar/sectors_jobs.json", sectors_jobs_ar_order_json.to_json
  end

  desc "Update Static JSON File"
  task update_static_json_file: :environment do
    # age_groups & alert_types & benefits & company_classifications & company_sizes & company_types & job_educations
    # experience_ranges & functional_areas & genders & job_experience_levels & job_application_statuses & job_types
    # languages & last_actives & marital_statuses & notice_periods & salary_ranges & visa_statuses

    full_static_obj = {}
    full_static_obj_ar = {}

    full_static_obj[:age_groups] = AgeGroup.all.map{|age_group| AgeGroupSerializer.new(age_group).serializable_object}
    full_static_obj_ar[:age_groups] = full_static_obj[:age_groups]

    full_static_obj[:alert_types] = AlertType.all.map{|alert_type| AlertTypeSerializer.new(alert_type).serializable_object}
    full_static_obj_ar[:alert_types] = AlertType.all.map{|alert_type| AlertTypeSerializer.new(alert_type).serializable_object(ar: true)}

    full_static_obj[:benefits] = Benefit.all.map{|benefit| BenefitSerializer.new(benefit).serializable_object}
    full_static_obj_ar[:benefits] = Benefit.all.map{|benefit| BenefitSerializer.new(benefit).serializable_object(ar: true)}

    full_static_obj[:company_classifications] = CompanyClassification.all.map{|company_classification| CompanyClassificationSerializer.new(company_classification).serializable_object}
    full_static_obj_ar[:company_classifications] = CompanyClassification.all.map{|company_classification| CompanyClassificationSerializer.new(company_classification).serializable_object(ar: true)}

    full_static_obj[:company_sizes] = CompanySize.all.map{|company_size| CompanySizeSerializer.new(company_size).serializable_object}
    full_static_obj_ar[:company_sizes] = full_static_obj[:company_sizes]

    full_static_obj[:company_types] = CompanyType.all.map{|company_type| CompanyTypeSerializer.new(company_type).serializable_object}
    full_static_obj_ar[:company_types] = CompanyType.all.map{|company_type| CompanyTypeSerializer.new(company_type).serializable_object(ar: true)}

    full_static_obj[:job_educations] = JobEducation.all.map{|job_education| JobEducationSerializer.new(job_education).serializable_object}
    full_static_obj_ar[:job_educations] = JobEducation.all.map{|job_education| JobEducationSerializer.new(job_education).serializable_object(ar: true)}

    full_static_obj[:experience_ranges] = ExperienceRange.all.map{|experience_range| ExperienceRangeSerializer.new(experience_range).serializable_object}
    full_static_obj_ar[:experience_ranges] = full_static_obj[:experience_ranges]

    full_static_obj[:functional_areas] = FunctionalArea.all.map{|functional_area| FunctionalAreaSerializer.new(functional_area).serializable_object}
    full_static_obj_ar[:functional_areas] = FunctionalArea.all.map{|functional_area| FunctionalAreaSerializer.new(functional_area).serializable_object(ar: true)}

    full_static_obj[:genders] = [{
                                     id: "male",
                                     name: "Male",
                                     code: "male"
                                 },
                                 {
                                     id: "female",
                                     name: "Female",
                                     code: "female"
                                 }]
    full_static_obj_ar[:genders] = [{
           id: "male",
           name: "ذكر",
           code: "male"
       },
       {
           id: "female",
           name: "أنثي",
           code: "female"
       }]

    full_static_obj[:job_experience_levels] = JobExperienceLevel.all.map{|job_experience_level| JobExperienceLevelSerializer.new(job_experience_level).serializable_object}
    full_static_obj_ar[:job_experience_levels] = JobExperienceLevel.all.map{|job_experience_level| JobExperienceLevelSerializer.new(job_experience_level).serializable_object(ar: true)}

    full_static_obj[:job_application_statuses] = JobApplicationStatus.all.map{|job_application_status| JobApplicationStatusSerializer.new(job_application_status).serializable_object}
    full_static_obj_ar[:job_application_statuses] = JobApplicationStatus.all.map{|job_application_status| JobApplicationStatusSerializer.new(job_application_status).serializable_object(ar: true)}

    full_static_obj[:job_types] = JobType.all.map{|job_type| JobTypeSerializer.new(job_type).serializable_object}
    full_static_obj_ar[:job_types] = JobType.all.map{|job_type| JobTypeSerializer.new(job_type).serializable_object(ar: true)}

    full_static_obj[:languages] = Language.all.map{|language| LanguageSerializer.new(language).serializable_object}
    full_static_obj_ar[:languages] = Language.all.map{|language| LanguageSerializer.new(language).serializable_object(ar: true)}

    full_static_obj[:last_actives] = [
        {
            id: "1 week",
            name: "1 Week"
        },
        {
            id: "1 month",
            name: "1 Month"
        },
        {
            id: "3 months",
            name: "3 Months"
        },
        {
            id: "6 months",
            name: "6 Months"
        }
    ]
    full_static_obj_ar[:last_actives] = [
        {
            id: "1 week",
            name: "1 أسبوع"
        },
        {
            id: "1 month",
            name: "1 شهر"
        },
        {
            id: "3 months",
            name: "3 شهور"
        },
        {
            id: "6 months",
            name: "6 شهور"
        }
    ]

    full_static_obj[:marital_statuses] = [
        {
            id: "married",
            name: "Married",
            code: "married"
        },
        {
            id: "single",
            name: "Single",
            code: "single"
        }
    ]
    full_static_obj_ar[:marital_statuses] = [
        {
            id: "married",
            name: "متزوج",
            code: "married"
        },
        {
            id: "single",
            name: "غير متزوج",
            code: "single"
        }
    ]

    full_static_obj[:notice_periods] = [
        {
            name: "Less than 1 Month",
            id: "0"
        },
        {
            name: "1 Month",
            id: "1"
        },
        {
            name: "2 Months",
            id: "2"
        },
        {
            name: "3 Months",
            id: "3"
        },
        {
            name: "4 Months",
            id: "4"
        },
        {
            name: "5 Months",
            id: "5"
        },
        {
            name: "6+ Months",
            id: "12"
        }
    ]
    full_static_obj_ar[:notice_periods] = [
        {
            name: "أقل من شهر",
            id: "0"
        },
        {
            name: "1 شهر",
            id: "1"
        },
        {
            name: "2 شهور",
            id: "2"
        },
        {
            name: "3 شهور",
            id: "3"
        },
        {
            name: "4 شهور",
            id: "4"
        },
        {
            name: "5 شهور",
            id: "5"
        },
        {
            name: "6+ شهور",
            id: "12"
        }
    ]

    full_static_obj[:salary_ranges] = SalaryRange.all.map{|salary_range| SalaryRangeSerializer.new(salary_range).serializable_object}
    full_static_obj_ar[:salary_ranges] = full_static_obj[:salary_ranges]

    full_static_obj[:visa_statuses] = VisaStatus.all.map{|visa_status| VisaStatusSerializer.new(visa_status).serializable_object}
    full_static_obj_ar[:visa_statuses] = VisaStatus.all.map{|visa_status| VisaStatusSerializer.new(visa_status).serializable_object(ar: true)}

    upload_json_to_s3 "en/static.json", full_static_obj.to_json
    upload_json_to_s3 "ar/static.json", full_static_obj_ar.to_json
  end
end