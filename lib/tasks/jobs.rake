namespace :mapper do


  desc 'map job status data'
  task job_status: :environment do
    table_name = 'job_statuses'
    records    = extract_data('jobstatus')
    records.each do |r|
      JobStatus.create({ id:     r[:jobstatusid],
                         status: r[:jobstatus] })
    end
    set_max_ids(table_name)
  end

  desc 'map jobs data'
  task jobs: :environment do
    options        = { value_converters: {
        jobstartdate: DateConverter,
        jobenddate:   DateConverter,
        createdate:   DateTimeConverter
    } }
    jobs_records   = extract_data('jobs', options)
    job_educations = extract_data('jobtoeducations')
    job_experience = extract_data('jobtoexperiencelevel')
    job_functions  = extract_data('jobtofunction')
    job_industry   = extract_data('jobtoindustries')
    job_location   = extract_data('jobtolocation')

    jobs_records.each do |r|
      user     = User.find_by_id(r[:userid])
      edu      = job_educations.select { |v| v[:jobid] == r[:jobid] }
      exp      = job_experience.select { |v| v[:jobid] == r[:jobid] }
      func     = job_functions.select { |v| v[:jobid] == r[:jobid] }
      sector   = job_industry.select { |v| v[:jobid] == r[:jobid] }
      location = job_location.select { |v| v[:jobid] == r[:jobid] }
      unless user.nil?
        company                        = user.companies.first
        # TODO: No Need to add benefits
        # job_description = unless r[:jobbenefits].nil?
        #   "#{r[:description]}<br><h2>Main Benefits</h2><br>#{r[:jobbenefits]}"
        # else
        #   r[:description]
        # end

        salary_range = if r[:startingsalary].nil? && r[:endingsalary].nil?
                         nil
                       elsif r[:startingsalary].nil?
                         SalaryRange.where("salary_from <= ? AND salary_to >= ?", r[:endingsalary], r[:endingsalary]).first
                       elsif r[:endingsalary].nil?
                         SalaryRange.where("salary_from <= ? AND salary_to >= ?", r[:startingsalary], r[:startingsalary]).first
                       else
                         SalaryRange.where("salary_from <= ? AND salary_to >= ?", r[:startingsalary], r[:endingsalary]).first
                       end

        job_end_date = if r[:jobenddate]
                         r[:jobenddate]
                       elsif r[:status]
                         (Date.today + 3.months)
                       else
                         Date.yesterday
                       end
        data                           = { id:                r[:jobid],
                                           user_id:           user.id,
                                           company_id:        company.id,
                                           title:             r[:title],
                                           job_type_id:       r[:jobtypeid],
                                           job_category_id:   r[:jobcategoryid],
                                           country_id:        r[:countryid],
                                           start_date:        r[:jobstartdate],
                                           end_date:          job_end_date,
                                           salary_range_id:   salary_range.try(:id),
                                           experience_from:   r[:experiencefrom],
                                           experience_to:     r[:experienceto],
                                           description:       r[:description],
                                           qualifications:    r[:professionalqualification],
                                           requirements:      r[:desiredskills],
                                           created_at:        r[:createdate],
                                           updated_at:        r[:createdate],
                                           active:            r[:status],
                                           deleted:           r[:isdeleted],
                                           views_count:       r[:views],
                                           job_status_id:     r[:jobstatusid],
                                           url:               r[:url],
                                           notification_type: r[:jobapplicationnotification]
        }
        data[:sector_id]               = sector.first[:jobindustriesid] unless sector.first.nil?
        data[:functional_area_id]      = func.first[:jobfunctionid] unless func.first.nil?
        data[:job_experience_level_id] = exp.first[:jobexperiencelevelid] unless exp.first.nil?
        data[:city_id]                 = location.first[:locationid] unless exp.first.nil?
        data[:job_education_id]        = edu.sort_by { |k| k[:jobeducationid] }.last[:jobeducationid] unless edu.first.nil?

        # set nil to zero values
        data                           = data.each { |k, v| data[k] = nil if v == 0 }

        job_record = Job.new(data)
        job_record.save(validate: false)
      end
      #
      Job.closed.update_all(job_status_id: 2)
    end
    set_max_ids('jobs')
  end

  desc 'map job application status data'
  task job_application_status: :environment do
    table_name = 'job_application_statuses'
    records    = extract_data('jobapplicationstatus')
    records.each do |r|
      JobApplicationStatus.create({ id:     r[:jobapplicationstatusid],
                                    status: r[:jobapplicationstatusname],
                                    order:  r[:jobapplicationstatusorder] })
    end
    set_max_ids(table_name)
  end

  desc 'map job applications data'
  task job_applications: :environment do
    table_name = 'job_applications'
    options    = { value_converters: {
        applydate: DateTimeConverter,
    } }
    records    = extract_data('jobapply', options)
    records.each do |r|
      user         = User.find_by_id(r[:userid])
      jobseeker = user.try(:jobseeker)
      resume       = JobseekerResume.find_by_id(r[:resumeid])
      job          = Job.find_by_id(r[:jobid])
      cover_letter = JobseekerCoverletter.find_by_id(r[:coverletterid])
      unless jobseeker.nil? or job.nil?
        j                          = JobApplication.new({ id:                        r[:applyjobid],
                                                          jobseeker_id:              jobseeker.id,
                                                          job_id:                    r[:jobid],
                                                          job_application_status_id: r[:applicationstatusid],
                                                          created_at:                r[:applydate],
                                                          updated_at:                r[:applydate]
                                                        })
        j.jobseeker_coverletter_id = r[:coverletterid] unless cover_letter.nil?
        j.jobseeker_resume_id      = r[:resumeid] unless resume.nil?
        j.skip_sending = true
        j.save!
      end
    end
    set_max_ids(table_name)
  end

  # TODO: Remove this task after stable
  desc 'map user_id to jobseeker_id'
  task job_applications_with_jobseeker: :environment do
    JobApplication.all.each do |job_application|
      jobseeker = job_application.user.try(:jobseeker)
      job_application.update_attribute(:jobseeker_id, jobseeker.id) if jobseeker
    end
    JobApplication.where(jobseeker_id: nil).destroy_all
  end

  desc 'map job applications status changes data'
  task job_applications_status_changes: :environment do
    table_name = 'job_application_status_changes'
    options    = { value_converters: {
        statuschangedat: DateTimeConverter,
    } }
    records    = extract_data('jobapplicationstatuschanges', options)
    records.each do |r|
      employer        = User.find_by_id(r[:userid])
      jobseeker       = User.find_by_id(r[:profileuserid])
      job_application = JobApplication.find_by_id(r[:applyjobid])
      unless employer.nil? or jobseeker.nil? or job_application.nil?
        status = JobApplicationStatusChange.new({ id:                 r[:statuschangeid],
                                                  job_application_status_id:      r[:statusid],
                                                  job_application_id: job_application.id,
                                                  employer_id:        employer.id,
                                                  jobseeker_id:       jobseeker.id,
                                                  comment:            r[:comment],
                                                  created_at:         r[:statuschangedat],
                                                  updated_at:         r[:statuschangedat]
                                                })
        status.save!
      end
    end

    set_max_ids(table_name)
  end

  desc 'map saved jobs'
  task saved_jobs: :environment do
    table_name = 'saved_jobs'
    records    = extract_data('savedjobs')
    records.each do |r|
      jobseeker_obj = User.find_by_id(r[:userid]).try(:jobseeker)
      next if jobseeker_obj.nil? || r[:jobid].nil? || Job.find_by_id(r[:jobid]).nil?
      SavedJob.create({id: r[:savedjobsid],
                       job_id: r[:jobid],
                       jobseeker_id: jobseeker_obj.id})
    end
    set_max_ids(table_name)
  end


  desc 'map saved jobs'
  task saved_job_searches: :environment do
    table_name = 'saved_job_searches'
    records    = extract_data('savedjobsearch')
    records.each do |r|
      jobseeker_obj = User.find_by_id(r[:userid]).try(:jobseeker)
      next if jobseeker_obj.nil?
      SavedJobSearch.create({ id: r[:savedjobsearchid],
                              jobseeker_id: jobseeker_obj.id,
                              title: r[:title],
                              alert_type_id: r[:alerttypeid],
                              web_url: r[:searchurl]
                            })
    end
    set_max_ids(table_name)
  end

  # TODO: Remove after create suggested candidates
  desc 'Save Suggested Candidates'
  task saved_suggested_candidates: :environment do
    Job.active.each do |job|
      job.delay(queue: 'save_suggested_candidates').set_suggested_candidates
    end
  end

  desc 'map all jobs data'

  task all_jobs: :environment do
    Rake::Task['mapper:job_status'].execute
    Rake::Task['mapper:jobs'].execute
    Rake::Task['mapper:job_application_status'].execute
    Rake::Task['mapper:job_applications'].execute
    Rake::Task['mapper:job_applications_status_changes'].execute
    Rake::Task['mapper:saved_jobs'].execute
    Rake::Task['mapper:saved_job_searches'].execute
  end
end
