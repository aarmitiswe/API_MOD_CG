namespace :mapper do

  desc 'map languages data'

  task languages: :environment do
    table_name   = 'languages'
    data_records = extract_data(table_name)
    data_records.each do |r|
      next if !r[:languageid] || !r[:language]
      language = Language.find_by(id:   r[:languageid]) || Language.create({
          id:   r[:languageid],
          name: r[:language],
      })
      if r[:languagecode] && r[:language] != 'default'
        language.public = true
      end
      language.save!
    end
    set_max_ids(table_name)
  end

  desc 'map sectors data'

  task sectors: :environment do
    table_name     = 'jobindustries'
    new_table_name = 'sectors'
    data_records   = extract_data(table_name)
    dummy_records  = [52, 46, 47, 50]
    data_records.each do |r|
      unless dummy_records.include?(r[:jobindustriesid])
        sector = Sector.create({ name:          r[:jobindustries],
                                 id:            r[:jobindustriesid],
                                 display_order: r[:displayorder] })
        r[:status] == 't' ? sector.deleted = false : sector.deleted = true
        sector.save!
      end
    end
    set_max_ids(new_table_name)
  end

  desc 'map job_experience_levels data'

  task job_experience_levels: :environment do
    table_name     = 'jobexperiencelevel'
    new_table_name = 'job_experience_levels'
    data_records   = extract_data(table_name)
    data_records.each do |r|
      level = JobExperienceLevel.create({ level:         r[:jobexperiencelevel],
                                          id:            r[:jobexperiencelevelid],
                                          display_order: r[:displayorder] })
      r[:status] == 't' ? level.deleted = false : level.deleted = true
      level.save!
    end
    set_max_ids(new_table_name)
  end

  desc 'map functional_areas data'

  task functional_areas: :environment do
    table_name     = 'jobfunctions'
    new_table_name = 'functional_areas'
    data_records   = extract_data(table_name)
    data_records.each do |r|
      area = FunctionalArea.create({ area:          r[:jobfunctions],
                                     id:            r[:jobfunctionid],
                                     display_order: r[:displayorder] })
      r[:status] == 't' ? area.deleted = false : area.deleted = true
      area.save!
    end
    set_max_ids(new_table_name)
  end

  desc 'map job_types data'

  task job_types: :environment do
    table_name     = 'jobtype'
    new_table_name = 'job_types'
    data_records   = extract_data(table_name)
    data_records.each do |r|
      type = JobType.create({ name:          r[:jobtype],
                              id:            r[:jobtypeid],
                              display_order: r[:displayorder] })
      r[:status] == 't' ? type.deleted = false : type.deleted = true
      type.save!
    end
    set_max_ids(new_table_name)
  end

  desc 'map job_categories data'

  task job_categories: :environment do
    table_name     = 'jobcategory'
    new_table_name = 'job_categories'
    data_records   = extract_data(table_name)
    data_records.each do |r|
      category = JobCategory.create({ name:          r[:jobcategory],
                                      id:            r[:jobcategoryid],
                                      display_order: r[:displayorder] })
      r[:status] == 't' ? category.deleted = false : category.deleted = true
      category.save!
    end
    set_max_ids(new_table_name)
  end

  desc 'map job_education data from v1 to v2'

  task job_education: :environment do
    table_name     = 'jobeducations'
    new_table_name = 'job_educations'
    data_records   = extract_data(table_name)
    data_records.each do |r|
      level = JobEducation.create({ level:        r[:jobeducations],
                                    id:           r[:jobeducationid],
                                    displayorder: r[:displayorder] })
      r[:status] == 't' ? level.deleted = false : level.deleted = true
      level.save!
    end
    set_max_ids(new_table_name)
  end

  desc 'map skills data'

  task skills: :environment do
    table_name = 'skills'
    skills     = extract_data('resumeskillmaster')
    skills.each do |s|
      record = Skill.create({ id:   s[:resumeskillmaster],
                              name: s[:resumeskills] })
      # record.save!
    end
    set_max_ids(table_name)
  end


  desc 'map tag_types data'

  task tag_types: :environment do
    table_name = 'tagtypes'
    new_table_name = 'tag_types'
    tag_types     = extract_data('tagtype')
    tag_types.each do |s|
      next if s[:tagtypeid].blank? || s[:tagtypeid].nil?
      record = TagType.create({ id:   s[:tagtypeid],
                              name: s[:tagtype] })
      record.save!
    end
    set_max_ids(new_table_name)
  end


  desc 'map tags data'
  task tags: :environment do
    table_name = 'tags'
    tags     = extract_data('tagmaster')
    tags.each do |s|
      next if s[:tags].blank?
      record = Tag.create({ id:   s[:tagmasterid],
                            name: s[:tags],
                            tag_type_id: s[:tagtypeid]
                          })
      # record.save!
    end
    set_max_ids(table_name)
  end

  desc 'map matching_percentage data from v1 to v2'

  task matching_percentage: :environment do
    table_name     = 'jobmatchingpercentages'
    new_table_name = 'job_matching_percentages'
    data_records   = extract_data(table_name)
    data_records.each do |r|
      job = JobMatchingPercentage.create({ id:                   r[:percentageid],
                                           country:              r[:country].to_f,
                                           city:                 r[:city].to_f,
                                           sector:               r[:sector].to_f,
                                           job_type:             r[:jobtype].to_f,
                                           education_level:      r[:educationlevel].to_f,
                                           years_of_experience:  r[:yearsofexperience].to_f,
                                           experience_level:     r[:experiencelevel].to_f,
                                           job_title:            r[:jobtitle].to_f,
                                           department:           r[:department].to_f,
                                           skills_focus_summary: r[:skillsfocussummary].to_f,
                                           expecting_salary:     r[:expectingsalary].to_f })
      job.save!
    end
    set_max_ids(new_table_name)
  end

  desc 'map email_templates data from v1 to v2'

  task email_templates: :environment do
    table_name     = 'templates'
    new_table_name = 'email_templates'
    data_records   = extract_data(table_name)
    data_records.each do |r|
      r[:templatebody].gsub!('${', '%{')
      template = EmailTemplate.create({ name: r[:templatename],
                                        id:   r[:templateid],
                                        body: r[:templatebody] })
      r[:status] == 't' ? template.deleted = false : template.deleted = true
      template.save!
    end
    set_max_ids(new_table_name)
  end

  desc 'map generic data data'

  task generic_tables: :environment do
    Rake::Task['mapper:languages'].execute
    Rake::Task['mapper:sectors'].execute
    Rake::Task['mapper:job_experience_levels'].execute
    Rake::Task['mapper:functional_areas'].execute
    Rake::Task['mapper:job_types'].execute
    Rake::Task['mapper:job_categories'].execute
    Rake::Task['mapper:job_education'].execute
    Rake::Task['mapper:skills'].execute
    Rake::Task['mapper:tag_types'].execute
    Rake::Task['mapper:tags'].execute
    Rake::Task['mapper:matching_percentage'].execute
    Rake::Task['mapper:email_templates'].execute
  end

end
