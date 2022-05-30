require 'nokogiri'
require 'aws-sdk'

def buildIndeedJob(job, xml,job_country,job_city,additional_val = 0)

  # Special Case for Saudi Jobs
  new_name = case job.id
    when 4967
      "Sales Executive - Riyadh مندوب مبيعات - الرياض"
    when 4965
      "Branch Head - Saudi Arabia - مدير فرع"
    when 3927
      "Business Development Manager - مسئول مبيعات تنفيذي"
    else
      nil
  end

  xml.job {
    xml.title new_name.nil? ? (additional_val.zero? ? job.title : "#{job.title} - Relocate to Dubai") : new_name
    xml.date ((Date.today - job.start_date).to_i % 30).days.ago
    xml.referencenumber job.id + additional_val # To handle different IDs
    xml.url "#{Rails.application.secrets[:FRONTEND]}/#{job.frontend_path(additional_val)}?source=indeed"
    xml.company job.company.try(:name)
    xml.city job_city
    xml.state job_city
    xml.country job_country
    xml.postalcode job.company.try(:po_box)
    xml.description "#{job.description} \n <h2>Job Requirements</h2> #{job.requirements}"
    xml.salary job.salary_range.try(:name).present? ? "$#{job.salary_range.try(:name)} per month" : "Not Specified"
    xml.education job.job_education.try(:level)
    xml.jobtype job.job_type.try(:name)
    xml.category job.job_category.try(:name).present? ? "#{job.job_category.try(:name)}" : "Not Specified"
    xml.experience "#{job.try(:experience_from)}+ years"
  }
end

def upload_to_s3 file_name, xml_builder
  aws_obj = Aws::S3::Object.new(Rails.application.secrets['AWS_BUCKET'], "jobs_xml/#{file_name}", {
      region: Rails.application.secrets['AWS_REGION'],
      secret_access_key: Rails.application.secrets['AWS_SECRET_ACCESS_KEY'],
      access_key_id: Rails.application.secrets['AWS_ACCESS_KEY_ID']
  })
  aws_obj.put({body: xml_builder.to_xml, acl:'public-read'})
  puts "Done Upload to S3"
end

def get_full_description_job job
  full_description = "#{job.description} \n <h2>Job Requirements</h2> #{job.requirements}"
  unless job.benefits.blank?
    full_description = "#{full_description} \n <h2>Benefits</h2><ul>#{job.benefits.map{|b| '<li>' + b.name + '</li>'}.join("")}</ul>"
  end
  full_description
end

namespace :xml_generator do

  desc 'Update Jobs XML Daily General'
  task write_daily_xml_jobs_general: :environment do
    # This one for PostJobFree & Learn4good & neuvoo
    jobs = Job.active.order(created_at: :desc)

    builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.response {
        xml.totalresults jobs.count
        xml.start 0
        xml.end jobs.count
        xml.results {
          jobs.each do |job|
            xml.result {
              xml.jobkey job.id
              xml.jobtitle job.title
              xml.company job.company.try(:name)
              xml.city job.city.try(:name)
              xml.country job.country.try(:name)
              xml.formattedLocation "#{job.city.try(:name)}, #{job.country.try(:name)}"
              xml.source "Bloovo"
              xml.date job.start_date
              xml.snippet job.description
              xml.requirements job.requirements
              xml.url "#{Rails.application.secrets[:FRONTEND]}/#{job.frontend_path}"
              xml.logo job.company.avatar(:original)
            }
          end
        }
      }
    end
    puts "Done Create XML Jobs"

    upload_to_s3 "jobs.xml", builder
  end

  desc 'Update Jobs XML Daily Trovit'
  task write_daily_xml_job_trovit: :environment do
    jobs = Job.active.order(created_at: :desc)

    #   Trovit
    trovit_builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.trovit {
        jobs.each do |job|
          xml.ad {
            xml.id job.id
            xml.title job.title
            xml.url "#{Rails.application.secrets[:FRONTEND]}/#{job.frontend_path}"
            xml.content job.description
            xml.company job.company.try(:name)
            xml.experience job.job_experience_level.try(:level)
            xml.requirements job.requirements
            xml.studies job.job_education.try(:level)
            xml.category job.sector.try(:name)
            xml.contract job.job_type.try(:name)
            xml.salary job.salary_range.try(:name)
            xml.city job.city.try(:name)
            xml.region job.country.try(:name)
            xml.date job.start_date.strftime("%d/%m/%Y")
            xml.expiration_date job.end_date.strftime("%d/%m/%Y")
            xml.logo job.company.avatar(:original)
          }
        end
      }
    end
    puts "Done Create XML Jobs Trovit"

    upload_to_s3 "trovit_jobs.xml", trovit_builder
  end

  desc 'Update Jobs XML Daily Career Jet'
  task write_daily_xml_job_careerjet: :environment do
    jobs = Job.active.order(created_at: :desc)

    #   Career Jet
    careerjet_builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.jobs {
        jobs.each do |job|
          xml.job {
            xml.id job.id
            xml.title job.title
            xml.url "#{Rails.application.secrets[:FRONTEND]}/#{job.frontend_path}"
            xml.location "#{job.city.try(:name)}, #{job.country.try(:name)}"
            xml.company job.company.try(:name)
            xml.company_url "#{Rails.application.secrets[:FRONTEND]}/#{job.company.try(:frontend_path)}"
            xml.description job.description
            xml.requirements job.requirements
            xml.contracttype job.job_type.try(:name)
            xml.salary job.salary_range.try(:name).present? ? "#{job.salary_range.try(:name)} USD" : "Not Specified"
            xml.apply_url "#{Rails.application.secrets[:FRONTEND]}/#{job.frontend_path}"
            xml.contact {
              xml.email job.company.try(:contact_email)
              xml.phone job.company.try(:phone)
            }
          }
        end
      }
    end
    puts "Done Create XML Jobs Career Jet"

    upload_to_s3 "career_jet_jobs.xml", careerjet_builder
  end

  desc 'Update Jobs XML Daily jooble'
  task write_daily_xml_job_jooble: :environment do
    jobs = Job.active.order(created_at: :desc)

    #   Jooble
    jooble_builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.jobs {
        jobs.each do |job|
          new_created_date = ((Date.today - job.created_at.to_date).to_i % 45).days.ago
          xml.job {
            xml.url "#{Rails.application.secrets[:FRONTEND]}/#{job.frontend_path}"
            xml.name job.title
            xml.region  job.city.try(:name)
            xml.country job.country.try(:name)
            xml.description get_full_description_job job
            xml.pubdate new_created_date.strftime("%m.%d.%Y") rescue nil
            xml.updated job.updated_at.nil? || job.updated_at < new_created_date ? new_created_date.strftime("%m.%d.%Y") : job.updated_at.strftime("%m.%d.%Y") rescue nil
            xml.salary job.salary_range.present? ? "#{job.salary_range.name_currency_format}" : "Not Specified"
            xml.company job.company.try(:name)
            xml.expire job.end_date.strftime("%m.%d.%Y") rescue nil
            xml.jobtype job.job_type.try(:name)
            xml.apply_url "#{Rails.application.secrets[:FRONTEND]}/#{job.frontend_path}"
          }
        end
      }
    end
    puts "Done Create XML Jobs Jooble"

    upload_to_s3 "jooble_jobs.xml", jooble_builder
  end
  
  desc 'Update Jobs XML Daily Indeed'
  task write_daily_xml_job_indeed: :environment do
    jobs =  Job.active.order(created_at: :desc)
    city_condition = "Dubai"
    location_replace = "Saudi"
    kuwait_replace = "Kuwait"

    #   Indeed
    indeed_builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.source {
        xml.publisher "Bloovo Job Site"
        xml.publisherurl Rails.application.secrets[:FRONTEND]
        xml.lastBuildDate Date.today
        jobs.each do |job|
          buildIndeedJob(job, xml,job.country.try(:name),job.city.try(:name), 0)

          # Duplicate Dubai jobs for Saudi
          if job.city.try(:name) == city_condition
            buildIndeedJob(job, xml,location_replace,location_replace, 20000)
            buildIndeedJob(job, xml,kuwait_replace,kuwait_replace, 50000)
          end

        end
      }
    end
    puts "Done Create XML Jobs Indeed"

    upload_to_s3 "indeed_jobs.xml", indeed_builder
    upload_to_s3 "jobrapido_jobs.xml", indeed_builder
    upload_to_s3 "recruit_jobs.xml", indeed_builder
  end
end