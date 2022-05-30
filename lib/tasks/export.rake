require "csv"
require 'axlsx'

namespace :exporter do

  CSV_FOLDER = "csv_data"

  desc "export active employers"
  task export_active_employers: :environment do

    CSV.open("export_active_employers.csv", "w") do |csv|
      csv << ["Email Employer"]
      User.active.employers.pluck(:email).each {|e| csv << [e]}
    end
  end


  desc "Export All Jobseekers_email"
  task export_all_jobseekers_email: :environment do

    CSV.open("export_all_jobseekers_email.csv", "w") do |csv|
      csv << ["Email Jobseeker"]

      User.jobseekers.pluck(:email).each {|e| csv << [e]}
    end
  end



  desc "Export All Jobseekers having Experience  as HR Manager"
  task export_all_jobseekers_having_experience_as_hr_manager: :environment do

    CSV.open("export_all_jobseekers_having_experience_as_hr_manager.csv", "w") do |csv|
      csv << ["Jobseeker Details with experience as HR Manager"]

      JobseekerExperience.where(position: 'HR Manager').uniq.
          map{|jse| csv << [jse.user.first_name, jse.user.last_name, jse.user.email,
                            jse.user.jobseeker.mobile_phone, jse.user.jobseeker.home_phone]}
    end

    puts "Export All Jobseekers having Experience  as HR Manager Completed"
  end


  desc "Export All Companies expiring in a Month"
  task export_all_companies_expiring_in_a_month: :environment  do
    CSV.open("export_all_companies_expiring_in_a_month.csv", "w") do |csv|
      csv << ["Company Id","Company Name", "Owner name", "Owner email", "Company Phone" ]

      Job.active.where(end_date: Date.today + 1.month).
          each {|j| csv << [j.company_id, j.company.name, "#{j.company.owner.first_name} #{j.company.owner.last_name}",
                            j.company.owner.email, j.company.phone]}
      puts "Export All Companies expiring in a Month Exported"
    end


  end



  desc "Jobs expiring within 30 days"
  task export_all_job_expire_within_30_days: :environment do

    CSV.open("export_all_job_expire_within_30_days.csv", "w") do |csv|
      csv << ["Company Name", "Job Title", "Expire Date"]
      Job.where("end_date <= (?) and end_date > (?)", 30.days.from_now, Date.today).
          each {|j| csv << [j.company.name, j.title, j.end_date]}
      puts "Jobs expiring within 30 days Exported"
    end
  end


  desc "Skills Name"
  task export_skills_name: :environment do
    CSV.open("skills_names.csv", "w") do |csv|
      csv << ["Skill Name"]
      Skill.pluck(:name).each {|e| csv << [e]}
    end
    puts "Skills is Exported"
  end

  desc "Title of Active Jobs"
  task export_title_active_jobs: :environment do
    CSV.open("active_jobs_title.csv", "w") do |csv|
      csv << ["Title Active Job"]
      Job.active.pluck(:title).each {|e| csv << [e]}
    end
    puts "Active Jobs is Exported"
  end

  desc "Positions of Jobseeker"
  task export_position_experience: :environment do
    CSV.open("experiences.csv", "w") do |csv|
      csv << ["Experience Position"]
      JobseekerExperience.pluck(:position).uniq.each {|e| csv << [e]}
    end
    puts "Position of Jobseeker"
  end

  desc "Load last 100 Companies Active"
  task load_last_100_companies: :environment do
    owner_ids = User.company_owners.active.order(:created_at).pluck(:id).last(100)

    owners = User.company_owners.where(id: owner_ids)

    CSV.open("100_companies.csv", "w") do |csv|
      csv << ["Company Name", "Login Email", "Contact Name", "Phone"]
      owners.each {|e| csv << [e.company.name, e.email, e.full_name, e.company.phone]}
    end
    puts "Export 100 random companies"
  end

  desc "Export Countries"
  task export_countries: :environment do
    CSV.open("#{CSV_FOLDER}/countries.csv", "w") do |csv|
      csv << ["id", "eng_name"]
      Country.all.each {|c| csv << [c.id, c.name]}
    end
    puts "Countries is Exported"
  end

  desc "Export Cities"
  task export_cities: :environment do
    CSV.open("#{CSV_FOLDER}/cities.csv", "w") do |csv|
      csv << ["id", "eng_name"]
      City.all.each {|c| csv << [c.id, c.name]}
    end
    puts "Cities is Exported"
  end

  desc "Export sectors"
  task export_sectors: :environment do
    CSV.open("#{CSV_FOLDER}/sectors.csv", "w") do |csv|
      csv << ["id", "eng_name"]
      Sector.all.each {|s| csv << [s.id, s.name]}
    end
    puts "Sectors is Exported"
  end

  desc "Export functional_areas"
  task export_functional_areas: :environment do
    CSV.open("#{CSV_FOLDER}/functional_areas.csv", "w") do |csv|
      csv << ["id", "eng_area"]
      FunctionalArea.all.each {|f| csv << [f.id, f.area]}
    end
    puts "FunctionalAreas is Exported"
  end

  desc "Export alert_types"
  task export_alert_types: :environment do
    CSV.open("#{CSV_FOLDER}/alert_types.csv", "w") do |csv|
      csv << ["id", "eng_name"]
      AlertType.all.each {|a| csv << [a.id, a.name]}
    end
    puts "AlertTypes is Exported"
  end

  desc "Export Company Classifications"
  task export_company_classifications: :environment do
    CSV.open("#{CSV_FOLDER}/company_classifications.csv", "w") do |csv|
      csv << ["id", "eng_name"]
      CompanyClassification.all.each {|c| csv << [c.id, c.name]}
    end
    puts "company_classifications is Exported"
  end

  desc "Export Company Types"
  task export_company_types: :environment do
    CSV.open("#{CSV_FOLDER}/company_types.csv", "w") do |csv|
      csv << ["id", "eng_name"]
      CompanyType.all.each {|e| csv << [e.id, e.name]}
    end
    puts "company_types is Exported"
  end

  desc "Export job educations"
  task export_job_educations: :environment do
    CSV.open("#{CSV_FOLDER}/job_educations.csv", "w") do |csv|
      csv << ["id", "eng_level"]
      JobEducation.all.each {|e| csv << [e.id, e.level]}
    end
    puts "job_educations is Exported"
  end

  desc "Export job experience levels"
  task export_job_experience_levels: :environment do
    CSV.open("#{CSV_FOLDER}/job_experience_levels.csv", "w") do |csv|
      csv << ["id", "eng_level"]
      JobExperienceLevel.all.each {|e| csv << [e.id, e.level]}
    end
    puts "job_experience_level is Exported"
  end

  desc "Export languages"
  task export_languages: :environment do
    CSV.open("#{CSV_FOLDER}/languages.csv", "w") do |csv|
      csv << ["id", "eng_name"]
      Language.all.each {|e| csv << [e.id, e.name]}
    end
    puts "languages is Exported"
  end

  desc "Export job_statuses"
  task export_job_statuses: :environment do
    CSV.open("#{CSV_FOLDER}/job_statuses.csv", "w") do |csv|
      csv << ["id", "eng_status"]
      JobStatus.all.each {|e| csv << [e.id, e.status]}
    end
    puts "job_statuses is Exported"
  end

  desc "Export packages"
  task export_packages: :environment do
    CSV.open("#{CSV_FOLDER}/packages.csv", "w") do |csv|
      csv << ["id", "Name", "Description", "Details"]
      Package.all.each {|p| csv << [p.id, p.name, p.description, p.details]}
    end
    puts "packages is Exported"
  end

  desc "Export job_categories"
  task export_job_categories: :environment do
    CSV.open("#{CSV_FOLDER}/job_categories.csv", "w") do |csv|
      csv << ["id", "eng_name"]
      JobCategory.all.each {|e| csv << [e.id, e.name]}
    end
    puts "job_categories is Exported"
  end


  desc "Export all candidates"
  task export_all_candidates: :environment do
    puts "================= Start Export All Candidates ==================="

    p = Axlsx::Package.new

    p.workbook.add_worksheet(name: "Export All Candidates") do |sheet|
      sheet.add_row ["#",
                     "Job Name",
                     "position oracle id",
                     "candidate name",
                     "email",
                     "id name",
                     "mobile number",
                     "candidate type",
                     "job id",
                     "candidate id",
                     "stage",
                     "stage start date",
                     "stage end date",
                     "interview date",
                     "joining date",
                     "added by"
                    ]

      JobApplication.order(created_at: 'desc').each_with_index  do |app, sel_index|
        job_application_status_changes = app.job_application_status_changes.order(created_at: 'asc')
        job_application_status_changes.each_with_index do |app_changes, sel_index_2|
          stage_created_on = app_changes.created_at.try(:strftime,"%b %d %Y %H:%M:%S")
          stage_created_end = job_application_status_changes[sel_index_2+1].try(:created_at).try(:strftime,"%b %d %Y %H:%M:%S")
          row = [sel_index_2 + 1,
                 app.job.title,
                 app.job.try(:position).try(:oracle_id),
                 app.jobseeker.full_name,
                 app.jobseeker.email,
                 app.jobseeker.id_number,
                 app.jobseeker.mobile_phone,
                 app.candidate_type,
                 app.job.id,
                 app.jobseeker.id,
                 app_changes.job_application_status.status,
                 stage_created_on,
                 stage_created_end,
                 app.interviews.try(:is_selected).try(:last).try(:appointment).try(:strftime, "%b %d %Y"),
                 app.offer_letters.try(:last).try(:joining_date).try(:strftime,"%b %d %Y"),
                 app_changes.try(:employer).try(:full_name)
          ]
          sheet.add_row row
        end
        puts "Exported Applicant: #{app.id} #{app.jobseeker.full_name}"
      end
    end
    p.use_shared_strings = true
    p.serialize("#{Rails.root}/export_all_candidates.xlsx")
    puts "================= End Export All Candidates ==================="
    puts "Find the at location: #{Rails.root}/export_all_candidates.xlsx"
  end


  desc "Export all jobs"
  task export_all_jobs: :environment do

    puts "================= Start Export All Jobs ==================="

    p = Axlsx::Package.new

    p.workbook.add_worksheet(name: "Export All Jobs") do |sheet|
      sheet.add_row ["#",
                     "position oracle id",
                     "job id oracle id",
                     "candidate type",
                     "job id ",
                     "job name",
                     "requisition status",
                     "unit",
                     "section",
                     "center",
                     "department",
                     "general department",
                     "deputy",
                     "job level",
                     "submitted by",
                     "employment type",
                     "approved date of job"
                    ]

      Job.order(created_at: 'desc').each_with_index do |job, sel_index|
        all_parent_orgnizations = job.try(:organization).try(:all_parent_orgnizations)
        all_parent_orgnizations ||= []
        row = [sel_index + 1,
               job.try(:position).try(:oracle_id),
               " ",
               " ",
               job.id,
               job.title,
               (job.requisition_status == 'sent') ? 'Pending': job.requisition_status,
               all_parent_orgnizations.select{|a| a.organization_type_id == 7}[0].try(:name),
               all_parent_orgnizations.select{|a| a.organization_type_id == 6}[0].try(:name),
               all_parent_orgnizations.select{|a| a.organization_type_id == 5}[0].try(:name),
               all_parent_orgnizations.select{|a| a.organization_type_id == 4}[0].try(:name),
               all_parent_orgnizations.select{|a| a.organization_type_id == 3}[0].try(:name),
               all_parent_orgnizations.select{|a| a.organization_type_id == 2}[0].try(:name),
               job.try(:organization).try(:name),
               job.try(:user).try(:full_name),
               job.employment_type,
               (job.requisition_status == 'approved') ? job.requisitions.approved.try(:last).try(:updated_at).try(:strftime,"%b %d %Y") : '-'
        ]
        puts "Exported Job: #{job.id} #{job.title}"
        sheet.add_row row

      end
    end
    p.use_shared_strings = true
    p.serialize("#{Rails.root}/export_all_jobs.xlsx")
    puts "================= END Export All Jobs ==================="
    puts "Find the at location: #{Rails.root}/export_all_jobs.csv"

  end


  desc "Export 1000 jobseekers & jobs"
  task export_1000_jobseekers: :environment do

    CSV.open("export_1000_jobseekers_email.csv", "w", {encoding: 'UTF-8'}) do |csv|
      csv.to_io.write "\uFEFF" # use CSV#to_io to write BOM directly
      first_row = ["Email", "First Name", "Last Name", "Gender", "Birthday", "Country", "City", "Phone", "Summary", "Current Salary",
       "Expected Salary", "Sector", "Functional Area", "Job Type", "Job Category", "Job Experience Level", "Nationality", "Marital Status"
      ]

      (1..3).each do |i|
        first_row << "Company #{i}"
        first_row << "Company Country #{i}"
        first_row << "Position #{i}"
        first_row << "Sector #{i}"
        first_row << "Start Date #{i}"
        first_row << "End Date #{i}"
      end

      (1..3).each do |i|
        first_row << "School #{i}"
        first_row << "Field Study #{i}"
        first_row << "Grade #{i}"
        first_row << "Start Date #{i}"
        first_row << "End Date #{i}"
      end

      (1..3).each do |i|
        first_row << "Resume #{i}"
      end

      (1..3).each do |i|
        first_row << "Cover Letter #{i}"
      end

      csv << first_row

      Jobseeker.active_complete.limit(1000).each do |jobseeker|
        user = jobseeker.user
        # jobseeker = user.jobseeker
        row = [user.email, user.first_name, user.last_name, user.gender_type, user.birthday, user.country.try(:name), user.city.try(:name),
               jobseeker.mobile_phone, jobseeker.summary, jobseeker.current_salary, jobseeker.expected_salary, jobseeker.sector.try(:name),
               jobseeker.functional_area.try(:area), jobseeker.job_type.try(:name), jobseeker.job_category.try(:name), jobseeker.job_experience_level.try(:level),
               jobseeker.nationality.try(:name), jobseeker.marital_status]

        experiences = jobseeker.jobseeker_experiences
        (1..3).each do |i|
          if experiences[i]
            row << experiences[i].company_name
            row << experiences[i].country.try(:name)
            row << experiences[i].position
            row << experiences[i].sector.try(:name)
            row << experiences[i].from
            row << experiences[i].to
          else
            row << "NA"
            row << "NA"
            row << "NA"
            row << "NA"
            row << "NA"
            row << "NA"
          end
        end

        educations = jobseeker.jobseeker_educations
        (1..3).each do |i|
          if educations[i]
            row << educations[i].school
            row << educations[i].field_of_study
            row << educations[i].grade
            row << educations[i].from
            row << educations[i].to
          else
            row << "NA"
            row << "NA"
            row << "NA"
            row << "NA"
            row << "NA"
          end
        end

        resumes = jobseeker.jobseeker_resumes

        (1..3).each do |i|
          if resumes[i]
            row << resumes[i].document(:origin)
          else
            row << "NA"
          end
        end

        covers = jobseeker.jobseeker_coverletters

        (1..3).each do |i|
          if covers[i]
            row << covers[i].document(:origin)
          else
            row << "NA"
          end
        end

        csv << row
      end
      puts "Done Export 1000 Jobseekers"
    end
  end

  desc "Export 1000 jobs"
  task export_1000_jobs: :environment do

    CSV.open("export_1000_jobs.csv", "w") do |csv|
      first_row = ["Company", "Title", "Description", "Qualifications", "Requirements", "Start Date", "End Date", "Experience From",
                   "Experience To", "Gender", "Marital Status", "Visa Status", "Sector", "Functional Area", "Job Education",
                   "Job Experience Level", "Country", "City"]

      csv << first_row

      Job.not_draft.where(deleted: false).each do |job|
        row = [job.company.try(:name), job.title, job.description, job.qualifications, job.requirements, job.start_date,
               job.end_date, job.experience_from, job.experience_to, job.gender_type, job.marital_status, job.visa_status.try(:name),
               job.sector.try(:name), job.functional_area.try(:area), job.job_education.try(:level), job.job_experience_level.try(:level),
               job.country.try(:name), job.city.try(:name)]

        csv << row
      end

      puts "Jobs Done"
    end
  end

  # Country, City, Sector, FunctionalArea, AlertType, CompanyClassification, CompanyType,
  # JobEducation, JobExperienceLevel, Language, JobStatus, Package, JobCategory
  desc "Export all Fixed Data to CSV Files"
  task export_all_data: :environment do
    Rake::Task['exporter:export_countries'].execute
    Rake::Task['exporter:export_cities'].execute
    Rake::Task['exporter:export_sectors'].execute
    Rake::Task['exporter:export_functional_areas'].execute
    Rake::Task['exporter:export_alert_types'].execute
    Rake::Task['exporter:export_company_classifications'].execute
    Rake::Task['exporter:export_company_types'].execute
    Rake::Task['exporter:export_job_educations'].execute
    Rake::Task['exporter:export_job_experience_levels'].execute
    Rake::Task['exporter:export_languages'].execute
    Rake::Task['exporter:export_job_statuses'].execute
    Rake::Task['exporter:export_packages'].execute
    Rake::Task['exporter:export_job_categories'].execute
  end
end