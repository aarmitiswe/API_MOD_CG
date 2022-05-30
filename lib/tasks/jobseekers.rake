namespace :mapper do

  ## populate jobseeker data TODO: integrate it with users task

  desc 'map jobseeker_profiles data'

  task jobseeker_profiles: :environment do
    new_table_name = 'jobseekers'
    reset_table_ids(new_table_name)
    options             = { value_converters: {
        userdetailsfieldsid: UserDetailsFieldsConverter,
    } }
    users               = User.where(role: 'jobseeker').order('id')
    user_details_values = extract_data('userdetailsvalues', options)

    #since we have different countries ids for nationalities so we need to map them to existing country ids to avoid duplication
    external_options    = { value_converters: {
        country: NationalityConverter
    } }

    user_nationality_records = extract_external_data('nationality', external_options)


    users.each do |u|
      user_selected_data     = user_details_values.select { |v| v[:userid] == u.id }
      jobseeker_profile_data = { user_id: u.id }
      user_selected_data.each do |d|
        unless d[:userdetailsselected].nil? or d[:userdetailsselected] == 0 or d[:userdetailsfieldsid].nil?
          jobseeker_profile_data[d[:userdetailsfieldsid]] = d[:userdetailsselected]
        end
      end

      jobseeker_profile_data[:created_at] = u.created_at
      jobseeker_profile_data[:updated_at] = u.updated_at

      # map jobseeker nationalities
      unless jobseeker_profile_data[:nationality_id].nil?
        fake_nationality                        = jobseeker_profile_data[:nationality_id]
        real_nationality                        = user_nationality_records.select { |v| v[:nationalityid] == fake_nationality }
        jobseeker_profile_data[:nationality_id] = real_nationality.first[:country]
      end

      jobseeker_profile_data.delete :job_experience_months
      jobseeker_obj = Jobseeker.new(jobseeker_profile_data)
      if jobseeker_obj.valid?
        jobseeker_obj.save!
      else
        jobseeker_obj.sector_id = nil
        if jobseeker_obj.save!
          p "Sector nil"
        else
          p "invalid jobseeker #{jobseeker_obj}, errors: #{jobseeker_obj.errors.full_messages}"
        end
      end
    end
    set_max_ids(new_table_name)
  end


  desc 'map jobseeker_experiences data'


  task jobseeker_experiences: :environment do
    table_name       = 'jobseeker_experiences'
    # reset_table_ids(table_name)

    work_records     = extract_data('work')
    position_records = extract_data('position')

    jobseeker_options      = { value_converters: {
        fromdate: DateConverter,
        todate:   DateConverter
    } }
    jobseeker_work_records = extract_data('userwork', jobseeker_options)
    jobseeker_work_attachments = extract_data('experiencecertificates')

    jobseeker_work_records.each do |u|
      work     = work_records.select { |v| v[:workid] == u[:workid] }
      position = position_records.select { |v| v[:positionid] == u[:positionid] }
      attachment = jobseeker_work_attachments.select{ |v| v[:userworkid] == u[:userworkid] }
      user     = User.find_by_id(u[:userid])
      unless user.nil? or user.jobseeker.nil? or position.first.nil? or work.first.nil?
        user.jobseeker.id
        position_name = position.first[:positionname]
        company_name  = work.first[:workname]
        attachment_name = attachment.first[:filename] if attachment && attachment.first

        record = JobseekerExperience.create({ id:           u[:userworkid],
                                              jobseeker_id: user.jobseeker.id,
                                              city_id:      u[:city],
                                              position:     position_name || "Not Defined",
                                              company_name: company_name || "Not Defined",
                                              description:  u[:roles],
                                              from:         u[:fromdate],
                                              to:           u[:todate],
                                              attachment:   attachment_name,
                                              created_at:   user.jobseeker.created_at,
                                              updated_at:   user.jobseeker.updated_at })
        record.save!
      end
    end
    set_max_ids(table_name)
  end

  desc 'map jobseeker_highschool data'
  task jobseeker_highschool: :environment do
    table_name       = 'jobseeker_educations'
    job_education_id = 6 # Highschool level
    schools          = extract_data('school')
    concentrations   = extract_data('concentration')

    highschool_options = { value_converters: {
        fromdate: DateConverter,
        todate:   DateConverter
    } }

    high_school_records = extract_data('userhighschool', highschool_options)
    high_school_records.each do |r|
      concentration       = concentrations.select { |v| v[:concentrationid] == r[:concentrationid] }
      r[:concentrationid] = concentration.first[:concentrationname] unless concentration.first.nil?
      school              = schools.select { |v| v[:schoolid] == r[:schoolid] }
      r[:schoolid]        = school.first[:schoolname] unless school.first.nil?

      user = User.find_by_id(r[:userid])
      unless user.nil? or user.jobseeker.nil?
        record = JobseekerEducation.create({ id:               r[:userhighschoolid],
                                             jobseeker_id:     user.jobseeker.id,
                                             city_id:          r[:city],
                                             country_id:       r[:country],
                                             from:             r[:fromdate],
                                             to:               r[:todate],
                                             school:           r[:schoolid],
                                             field_of_study:   r[:concentrationid],
                                             grade:            r[:grade],
                                             job_education_id: job_education_id,
                                             created_at:       user.jobseeker.created_at,
                                             updated_at:       user.jobseeker.updated_at })
        record.save!
      end
    end
    set_max_ids(table_name)

  end

  desc 'map jobseeker_college data'

  task jobseeker_college: :environment do
    table_name     = 'jobseeker_educations'
    # job_education_id = 13 # Bachelor Degree
    colleges       = extract_data('college')
    concentrations = extract_data('concentration')
    edu_certificates = extract_data('educationcertificates')

    college_options = { value_converters: {
        fromdate: DateConverter,
        todate:   DateConverter
    } }

    college_records = extract_data('usercollege', college_options)
    college_records.each do |r|
      concentration       = concentrations.select { |v| v[:concentrationid] == r[:concentrationid] }
      concentration_name = unless concentration.first.nil?
                             if !r[:fieldofstudy].nil? && !concentration.first[:concentrationname].nil?
                               "#{r[:fieldofstudy]}, #{concentration.first[:concentrationname]}"
                             else
                               r[:fieldofstudy] || concentration.first[:concentrationname]
                             end
                           else
                             r[:fieldofstudy]
                           end

      college             = colleges.select { |v| v[:collegeid] == r[:collegeid] }
      r[:collegeid]       = college.first[:collegename] unless college.first.nil?

      edu_cert = edu_certificates.select { |v| v[:usercollegeid] == r[:usercollegeid] }
      edu_cert_name = edu_cert.first[:filename] unless edu_cert.first.nil?

      user = User.find_by_id(r[:userid])
      unless user.nil? or user.jobseeker.nil?
        record = JobseekerEducation.create({ jobseeker_id:   user.jobseeker.id,
                                             city_id:        r[:city],
                                             country_id:     r[:country],
                                             from:           r[:fromdate],
                                             to:             r[:todate],
                                             school:         r[:collegeid],
                                             field_of_study: concentration_name,
                                             grade:          r[:grade],
                                             attachment:     edu_cert_name,
                                             # job_education_id:     job_education_id,
                                             created_at:     user.jobseeker.created_at,
                                             updated_at:     user.jobseeker.updated_at })
        record.save!
      end
    end
    set_max_ids(table_name)
  end

  desc 'map jobseeker_certificates data'
  task jobseeker_certificates: :environment do
    table_name        = 'jobseeker_certificates'
    options           = { value_converters: {
        createddate: DateTimeConverter
    } }
    jobseeker_certificates = extract_data('usercertificates', options)
    jobseeker_certificates.each do |r|
      user = User.find_by_id(r[:userid])
      unless user.nil? or user.jobseeker.nil?
        record = JobseekerCertificate.create({ id: r[:usercertificateid],
                                               jobseeker_id: user.jobseeker.id,
                                               name: r[:name],
                                               institute: r[:designation],
                                               attachment: r[:filefullname],
                                               grade: r[:grade],
                                               from: r[:fromdate],
                                               to: r[:todate]})
        record.save!
      end
    end
    set_max_ids(table_name)
  end

  desc 'map jobseeker_resumes data'

  task jobseeker_resumes: :environment do
    table_name        = 'jobseeker_resumes'
    options           = { value_converters: {
        createddate: DateTimeConverter
    } }
    jobseeker_resumes = extract_data('resume', options)
    jobseeker_resumes.each do |r|
      user = User.find_by_id(r[:userid])
      unless user.nil? or user.jobseeker.nil?
        record = JobseekerResume.create({ id:           r[:resumeid],
                                          jobseeker_id: user.jobseeker.id,
                                          created_at:   r[:createddate],
                                          updated_at:   r[:createddate],
                                          title:        r[:name],
                                          file_path:    r[:resumefile],
                                          is_deleted: false })
        r[:isdefault] == 't' ? record.default = true : record.default = false
        record.save!
      end
    end
    set_max_ids(table_name)
  end

  desc 'map jobseeker_coverletters data'

  task jobseeker_coverletters: :environment do
    table_name             = 'jobseeker_coverletters'
    options                = { value_converters: {
        createddate: DateTimeConverter
    } }
    jobseeker_coverletters = extract_data('coverletters', options)
    jobseeker_coverletters.each do |r|
      user = User.find_by_id(r[:userid])
      unless user.nil? or user.jobseeker.nil?
        record = JobseekerCoverletter.create({ id:           r[:resumeid],
                                               jobseeker_id: user.jobseeker.id,
                                               created_at:   r[:createddate],
                                               updated_at:   r[:createddate],
                                               title:        r[:title],
                                               file_path:    r[:filename],
                                               description:  r[:description] })
        r[:isdefault] == 't' ? record.default = true : record.default = false
        record.save!
      end
    end
    set_max_ids(table_name)
  end

  desc 'map jobseeker_skills data'

  task jobseeker_skills: :environment do
    table_name       = 'jobseeker_skills'
    jobseeker_skills = extract_data('userskills')
    jobseeker_skills.each do |r|
      jobseeker_id = get_jobseeker_id(r[:userid])
      skill        = Skill.find_by_id(r[:skillid])
      unless jobseeker_id.nil? or r[:skillid].nil? or skill.nil?
        r[:skilltypeid] ||= 2 # default is 2 if it is empty

        record = JobseekerSkill.create({ id:           r[:userskillid],
                                         jobseeker_id: jobseeker_id,
                                         skill_id:     r[:skillid],
                                         level:        r[:skilltypeid] })
        # record.save!
      end
    end
    set_max_ids(table_name)
  end

  desc 'map jobseeker_tags data'

  task jobseeker_tags: :environment do
    table_name       = 'jobseeker_tags'
    jobseeker_tags = extract_data('tags')
    jobseeker_tags.each do |r|
      jobseeker_id = get_jobseeker_id(r[:keyid])
      tag_type        = TagType.find_by_id(r[:tagtypeid])
      tag        = Tag.find_by_id(r[:tagmasterid])
      unless jobseeker_id.nil? or tag.nil? or tag_type.nil?
        tag.update_attribute(:tag_type_id, r[:tagtypeid])

        record = JobseekerTag.create({ id:           r[:tagid],
                                         jobseeker_id: jobseeker_id,
                                         tag_id:     r[:tagmasterid] })
        # record.save!
      end
    end
    set_max_ids(table_name)
  end


  desc 'map jobseeker profile views'

  task jobseeker_profile_views: :environment do
    table_name   = 'jobseeker_profile_views'
    options      = { value_converters: {
        vieweddate: DateTimeConverter
    } }
    data_records = extract_data('usersprofileviews', options)
    data_records.each do |r|
      employer  = User.employers.find_by_id(r[:userid])
      next if employer.nil?
      company_user = employer.company_users.first
      next if company_user.nil?
      jobseeker_user = User.find_by_id(r[:profileuserid])
      jobseeker = jobseeker_user.try(:jobseeker)
      company = company_user.company
      unless company_user.nil? or jobseeker.nil?
        record = JobseekerProfileView.create({ id:           r[:userprofileviewid],
                                               company_user_id:  company_user.id,
                                               jobseeker_id: jobseeker.id,
                                               company_id: company.id,
                                               created_at:   r[:vieweddate],
                                               updated_at:   r[:vieweddate] })
        # record.save
      end
      set_max_ids(table_name)

    end
  end

  desc 'update current profile views'
  task update_current_jobseeker_profile_views: :environment do
    # Set company_id
    JobseekerProfileView.where(company_id: nil).each do |jobseeker_profile_view|
      company = jobseeker_profile_view.company_user.company
      jobseeker_profile_view.update_attribute(:company_id, company.id)
    end

    # Delete any duplication per day
    jobseeker_profile_views_grouped = JobseekerProfileView
                                          .select('jobseeker_profile_views.company_id as view_company_id, count(*) as viewers_count, date(created_at) as view_date')
                                          .group(['jobseeker_profile_views.company_id', 'date(created_at)'])
                                          .having('count(*) > 1')

    jobseeker_profile_views_grouped.each do |jobseeker_profile_view|
      destroy_views = JobseekerProfileView.where("company_id = ? AND date(created_at) = ?", jobseeker_profile_view.view_company_id, jobseeker_profile_view.view_date)
      first_view = destroy_views.first
      JobseekerProfileView.where.not(id: first_view.id).where("company_id = ? AND date(created_at) = ?", jobseeker_profile_view.view_company_id, jobseeker_profile_view.view_date).destroy_all
    end
  end

  desc 'map all jobseeker data'
  task jobseeker: :environment do
    Rake::Task['mapper:jobseeker_profiles'].execute
    Rake::Task['mapper:jobseeker_experiences'].execute
    Rake::Task['mapper:jobseeker_highschool'].execute
    Rake::Task['mapper:jobseeker_college'].execute
    Rake::Task['mapper:jobseeker_resumes'].execute
    Rake::Task['mapper:jobseeker_coverletters'].execute
    Rake::Task['mapper:jobseeker_certificates'].execute
    Rake::Task['mapper:jobseeker_skills'].execute
    Rake::Task['mapper:jobseeker_tags'].execute
    Rake::Task['mapper:jobseeker_profile_views'].execute
    Rake::Task['mapper:update_current_jobseeker_profile_views'].execute
  end


end
