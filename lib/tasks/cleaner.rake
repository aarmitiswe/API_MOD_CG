require 'net/http'
require 'json'

require 'smarter_csv'
require 'date'
require 'pp'

require 'helpers/data_converter'

namespace :cleaner do

  desc 'clean languages'
  task clean_languages: :environment do
    dup_languages = Language.select('lower(languages.name)::text as lan_name, count(*) as lan_count').group('lower(languages.name)').having('count(*) > 1')

    dup_languages.each do |dup_language|
      puts dup_language.lan_name
      puts dup_language.lan_count

      languages = Language.where("lower(name) = ?", dup_language.lan_name.downcase)
      languages[1..-1].each do |lan|
        jobseekers = Jobseeker.where("languages LIKE '?'", lan.id)
        jobseekers.each do |jobseeker|
          old_lan = jobseeker.languages
          new_lan = old_lan.sub("#{lan.id}", "#{languages[0].id}")
          jobseeker.update_attribute(:languages, new_lan)
        end

        jobs = Job.where("languages LIKE '?'", lan.id)
        jobs.each do |job|

          old_lan = job.languages
          new_lan = old_lan.sub("#{lan.id}", "#{languages[0].id}")
          job.update_attribute(:languages, new_lan)
        end

        Language.find_by_id(lan.id).destroy
      end
    end

    removed_languages = ["kashmiri",
                         "System.Collections.Generic.List`1[System.String]",
                         "thulu",
                         "Tulu"]

    Language.where(name: removed_languages).destroy_all
  end

  desc 'Set country_id in City Table'
  task set_country_id: :environment do
    City.where(country_id: nil).where.not(state_id: nil).each do |city|
      state = city.state
      city.update_attribute(:country_id, state.country_id)
    end
  end

  desc 'Remove Duplicate City'
  task clean_dup_cities: :environment do
    dup_cities = City.select("(cities.name)::text as city_name, (cities.country_id) as city_country_id, count(*) as city_count").group(['cities.name', 'cities.country_id']).having('count(*) > 1')
    dup_cities.each do |dup_city|
      cities = City.where(name: dup_city.city_name,country_id: dup_city.city_country_id)
      first_city = cities.first
      cities[1..-1].each do |city|
        User.where(city_id: city.id).update_all(city_id: first_city.id)
        Jobseeker.where(current_city_id: city.id).update_all(current_city_id: first_city.id)
        Job.where(city_id: city.id).update_all(city_id: first_city.id)
        Company.where(city_id: city.id).update_all(city_id: first_city.id)
        Company.where(current_city_id: city.id).update_all(current_city_id: first_city.id)

        JobseekerEducation.where(city_id: city.id).update_all(city_id: first_city.id)
        JobseekerExperience.where(city_id: city.id).update_all(city_id: first_city.id)

        city.destroy
      end
    end

  #   Clean city with wrong country
    City.where(name: 'Kandahar', id: Country.find_by_name('United Arab Emirates')).destroy_all
  end

  desc 'Fill Nil Country_id with exist city'
  task fill_country_id: :environment do
    City.all.each do |city|
      User.where("country_id IS NULL OR country_id = 0").where(city_id: city.id).update_all(country_id: city.country_id)
      Jobseeker.where("current_country_id IS NULL OR current_country_id = 0").where(current_city_id: city.id).update_all(current_country_id: city.country_id)
      Job.where("country_id IS NULL OR country_id = 0").where(city_id: city.id).update_all(country_id: city.country_id)
      Company.where("country_id IS NULL OR country_id = 0").where(city_id: city.id).update_all(country_id: city.country_id)
      Company.where("current_country_id IS NULL OR current_country_id = 0").where(current_city_id: city.id).update_all(current_country_id: city.country_id)

      JobseekerEducation.where("country_id IS NULL OR country_id = 0").where(city_id: city.id).update_all(country_id: city.country_id)
      JobseekerExperience.where("country_id IS NULL OR country_id = 0").where(city_id: city.id).update_all(country_id: city.country_id)

      # Country Wrong
      User.where.not(country_id: city.country_id).where(city_id: city.id).update_all(country_id: city.country_id)
      Jobseeker.where.not(current_country_id:city.country_id).where(current_city_id: city.id).update_all(current_country_id: city.country_id)
      Job.where.not(country_id: city.country_id).where(city_id: city.id).update_all(country_id: city.country_id)
      Company.where.not(country_id: city.country_id).where(city_id: city.id).update_all(country_id: city.country_id)
      Company.where.not(current_country_id:city.country_id).where(current_city_id: city.id).update_all(current_country_id: city.country_id)

      JobseekerEducation.where.not(country_id: city.country_id).where(city_id: city.id).update_all(country_id: city.country_id)
      JobseekerExperience.where.not(country_id: city.country_id).where(city_id: city.id).update_all(country_id: city.country_id)
    end
  end

  desc 'Force Fill For City'
  task fill_city_id: :environment do
    country_with_city = [
        {country: "United Arab Emirates", city: "Dubai"},
        {country: "Egypt", city: "Cairo"},
        {country: "Kuwait", city: "Al Kuwait"},
        {country: "Qatar", city: "Doha"},
        {country: "Bahrain", city: "Manama"},
        {country: "Oman", city: "Muscat"},
        {country: "Saudi Arabia", city: "Riyadh"},
        {country: "Lebanon", city: "Beirut"},
        {country: "India", city: "Delhi"},
        {country: "Pakistan", city: "Lahore"},
        {country: "Jordan", city: "Amman"},
        {country: "Turkey", city: "İstanbul"},
        {country: "United Kingdom", city: "London"},
        {country: "United States", city: "Washington, D.C."}
    ]

    country_with_city.each do |record|
      city = City.find_by_name(record[:city])
      country = Country.find_by_name(record[:country])

      puts record if city.nil? || country.nil?
      User.where(country_id: country.id).where("city_id IS NULL OR city_id = 0").update_all(city_id: city.id)
      Jobseeker.where(current_country_id: country.id).where("current_city_id IS NULL OR current_city_id = 0").update_all(current_city_id: city.id)
      Job.where(country_id: country.id).where("city_id IS NULL OR city_id = 0").update_all(city_id: city.id)
      Company.where(country_id: country.id).where("city_id IS NULL OR city_id = 0").update_all(city_id: city.id)
      Company.where(current_country_id: country.id).where("current_city_id IS NULL OR current_city_id = 0").update_all(current_city_id: city.id)

      JobseekerEducation.where(country_id: country.id).where("city_id IS NULL OR city_id = 0").update_all(city_id: city.id)
      JobseekerExperience.where(country_id: country.id).where("city_id IS NULL OR city_id = 0").update_all(city_id: city.id)
    end
  end

  desc 'Clean blank cities with exist countries'
  task clean_blank_cities_with_exist_countries: :environment do
    Country.all.each do |country|

      User.where(country_id: country.id).where("city_id IS NULL OR city_id = 0").update_all(city_id: country.cities.first.id)
      Jobseeker.where(current_country_id: country.id).where("current_city_id IS NULL OR current_city_id = 0").update_all(current_city_id: country.cities.first.id)
      Job.where(country_id: country.id).where("city_id IS NULL OR city_id = 0").update_all(city_id: country.cities.first.id)
      Company.where(country_id: country.id).where("city_id IS NULL OR city_id = 0").update_all(city_id: country.cities.first.id)
      Company.where(current_country_id: country.id).where("current_city_id IS NULL OR current_city_id = 0").update_all(current_city_id: country.cities.first.id)

      JobseekerEducation.where(country_id: country.id).where("city_id IS NULL OR city_id = 0").update_all(city_id: country.cities.first.id)
      JobseekerExperience.where(country_id: country.id).where("city_id IS NULL OR city_id = 0").update_all(city_id: country.cities.first.id)
    end
  end

  desc 'Clean Sector'
  task sector_clean: :environment do
    removed_sec = Sector.find_by_name('Venture Capital & Private Equity')
    new_sec = Sector.find_by_name('Private Equity & Venture Capital')
    if removed_sec.present? && new_sec.present?
      Jobseeker.where(sector_id: removed_sec.id).update_all(sector_id: new_sec.id)
      Company.where(sector_id: removed_sec.id).update_all(sector_id: new_sec.id)
      removed_sec.destroy
    end
  end

  desc 'Clean CompanySize'
  task company_size_clean: :environment do
    CompanySize.find_by_size('30-35').update_attribute(:active, false)
  end

  desc 'Clean Jobs'
  task clean_jobs: :environment do
    Job.where(end_date: nil).update_all(end_date: (Date.today + 3.months))
  end

  desc 'Change Admins to Owner'
  task change_admins_to_owner: :environment do
    User.where(role: ["company_admin", "company_user"]).active.each do |user|
      # Delete employers without company
      unless user.company
        user.destroy
        next
      end
      owner = user.company.owner if user.company
      if owner.nil?
        owner = user.company.admins.first || user.company.users.first
        owner.update_attribute(:role, "company_owner")
      end
      if owner && owner.active == false
        owner.deleted = false
        owner.active = true
        unless owner.save(validate: false)
          puts owner.email
          puts owner.errors.full_messages
        end
      end
    end
  end

  desc 'Clean Experinece'
  task clean_experineces: :environment do
    experiences = JobseekerExperience.joins(:jobseeker, :user)
                      .where("jobseeker_experiences.city_id IS NULL OR jobseeker_experiences.city_id = 0")
                      .where("users.city_id IS NOT NULL")

    experiences.each do |exp|
      exp.update_attributes(country_id: exp.user.country_id, city_id: exp.user.city_id)
    end
  end

  desc 'Order Job Education Table'
  task reorder_job_education: :environment do
    job_education_levels = ["High School","Diploma","Bachelor Degree","Masters Degree","MBA","Doctorate"]
    job_education_levels.each_with_index do |level, index|
      JobEducation.find_by_level(level).update_attribute(:displayorder, index + 1)
    end
  end


  desc 'update years_of_experience'
  task update_years_of_experience: :environment do
    jobseekers_years_exp = Jobseeker
                               .select("final_jobseekers.jobseeker_id, final_jobseekers.exp, final_jobseekers.exp_years")
                               .from(
                                   Jobseeker
                                       .where(years_of_experience: nil)
                                       .joins("INNER JOIN jobseeker_experiences ON jobseeker_experiences.jobseeker_id = jobseekers.id INNER JOIN jobseekers AS b ON b.id = jobseekers.id")
                                       .where("jobseeker_experiences.from IS NOT NULL")
                                       .group("jobseekers.id")
                                       .select("jobseekers.*, jobseekers.id as jobseeker_id, jobseekers.years_of_experience as exp, extract(year from age(COALESCE(MAX(jobseeker_experiences.to), '03-21-2017'), MIN(jobseeker_experiences.from))) as exp_years"), :final_jobseekers
                               )

    jobseekers_years_exp.each do |record|
      obj = Jobseeker.find_by_id(record.jobseeker_id)
      obj.update_attribute(:years_of_experience, record.exp_years)
    end
    Jobseeker.where(years_of_experience: nil).update_all(years_of_experience: 0)
  end

  desc 'expired old jobs'
  task expired_old_jobs: :environment do
    Job.where("active = TRUE AND deleted = FALSE AND job_type_id = 2 AND start_date < '2016-08-01'::date AND end_date >= ?", Date.today).update_all(end_date: Date.yesterday)
  end

  desc 'Deactivate Companies'
  task deactivate_companies: :environment do
    User.employers.where(active: false).each {
        |u| u.companies.first.update(active: false); u.companies.first.jobs.update_all(active: false);
    }
  end

  desc 'reset all primary keys'
  task reset_all_primary_keys: :environment do
    ActiveRecord::Base.connection.tables.each do |table_name|
      ActiveRecord::Base.connection.reset_pk_sequence!(table_name)
    end
  end


  desc 'clean and build featured companies'
  task clean_build_featured_companies: :environment do

    feature_company_ids = [3604,3329,3821,3687,3343,3822,3812,3802,1490,3765,
                            3669,1864,3823,3648,3572,907,3246,3310,
                            3678,3656,3558,3332,3328,3601]

    # destroy all featured companies
    FeaturedCompany.destroy_all


    feature_company_ids.each do |fc_id|
      FeaturedCompany.create({company_id:fc_id}) if Company.find_by_id(fc_id).present?
    end



  end

  desc'cleaner dup sectors'
  task remove_dup_sectors: :environment do
    sector_hash = {
        "117" => 3,
        "89" => 94,
        "137" => 195,
        "69" => 64,
        "191" => 196,
        "66" => 190,
        "58" => 155,
        "122" => 199,
        "168" => 199,
        "5" => 7,
        "112" => 201,
        "200" => 201,
        "179" => 86,
        "84" => 86,
        "114" => 79,
        "143" => 144,
        "159" => 94,
        "146" => 144,
        "151" => 150,
        "6" => 198,
        "61" => 155,
        "134" => 125,
        "108" => 201,
        "109" => 201,
        "92" => 93,
        "164" => 125,
        "138" => 201,
        "59" => 155,
        "110" => 201,
        "62" => 155,
        "170" => 155,
        "147" => 149,
        "123" => 125,
        "67" => 190,
        "72" => 71,
        "73" => 71,
        "97" => 102,
        "121" => 2,
        "135" => 158,
        "157" => 158,
        "77" => 71,
        "203" => 155,
        "140" => 201,
        "169" => 106,
        "75" => 74,
        "152" => 197,
        "101" => 198,
    }

    sector_hash.each do |old_id, new_id|
      old_sector = Sector.find_by_id(old_id.to_i)
      new_sector = Sector.find_by_id(new_id.to_i)

      if !old_sector.nil? && !new_sector.nil?
        Jobseeker.where(sector_id: old_id).update_all(sector_id: new_id)
        Job.where(sector_id: old_id).update_all(sector_id: new_id)
        Company.where(sector_id: old_id).update_all(sector_id: new_id)
        JobseekerExperience.where(sector_id: old_id).update_all(sector_id: new_id)

        old_sector.destroy

      end
    end

    Sector.find(93).update_attribute(:name, "Healthcare Services")
    Sector.find(11).update_attribute(:name, "General Trading")
  end

  desc 'remove wrong cities from UAE'
  task clean_uae_cities: :environment do
    cities_names = ['Deira', 'Burjman']
    dubai_city_id = City.find_by_name('Dubai').id

    cities_names.each do |city_name|
      old_city = City.find_by_name(city_name)
      old_city_id = old_city.id

      User.where(city_id: old_city_id).update_all(city_id: dubai_city_id)
      Jobseeker.where(current_city_id: old_city_id).update_all(current_city_id: dubai_city_id)

      Company.where(city_id: old_city_id).update_all(city_id: dubai_city_id)
      Company.where(current_city_id: old_city_id).update_all(current_city_id: dubai_city_id)

      Job.where(city_id: old_city_id).update_all(city_id: dubai_city_id)

      JobseekerEducation.where(city_id: old_city_id).update_all(city_id: dubai_city_id)
      JobseekerExperience.where(city_id: old_city_id).update_all(city_id: dubai_city_id)

      old_city.destroy
      puts "Destroy #{old_city.name}"
    end
  end

  desc 'Add default  Value to completed_at column'
  task add_value_for_exist_completed_jobseekers: :environment do
    Jobseeker.active_complete.where(completed_at: nil).each do |j|
      j.update_column(:completed_at, j.updated_at)
      puts "#{j.id}"
    end
  end

  desc 'Add Kosovo & Citiies'
  task add_kosovo: :environment do
    # c = Country.create(name: "Kosovo", iso: "XKX", nationality: "Kosovan", latitude: 42.6026, longitude: 20.9030)
    c = Country.where(name: 'Kosovo').first
    s = State.find_by_name('Kosovo')

    city_names = ["Suva Reka", "Prizren", "Orahovac", "Ferizaj", "Mališevo", "Peć", "Lipljan", "Gjakova", "Skenderaj", "Podujevo", "Vitina", "Mitrovica", "Deçan", "Gjilan", "Istok", "Vučitrn", "Klina", "Glogovac", "Kosovo Polje"]
    city_names.each do |name|
      city = City.create(name: name, country_id: c.id, state_id: s.id)
      puts "id: #{city.id}"
    end
  end

  desc 'Remove duplicate from job applications'
  task remove_duplicate_job_applications: :environment do
    dub_applications = JobApplication.select(:jobseeker_id,:job_id, :job_application_status_id).group(:jobseeker_id, :job_id, :job_application_status_id).having("count(*) > 1")

    dub_applications.each do |application|
      same_records = JobApplication.where(jobseeker_id: application.jobseeker_id, job_id: application.job_id, job_application_status_id: application.job_application_status_id)
      same_records[1..-1].each {|rec| rec.destroy } if same_records.size > 1
    end

    puts "Clean Job Applications same Jobseeker/Job/Status"
  end

  desc 'Remove duplicate from CompanyFollowers'
  task remove_duplicate_company_followers: :environment do
    dup_com_followers = CompanyFollower.select(:company_id, :jobseeker_id).group(:company_id, :jobseeker_id).having("count(*) > 1")

    dup_com_followers.each do |com_follower|
      same_records = CompanyFollower.where(jobseeker_id: com_follower.jobseeker_id, company_id: com_follower.company_id)
      same_records[1..-1].each {|rec| rec.destroy } if same_records.size > 1
    end

    puts "Clean Company Followers same Company Follower"
  end

  desc 'Remove all data'
  task remove_all_data: :environment do
    JobApplication.destroy_all
    Position.destroy_all
    Grade.destroy_all

    Job.destroy_all
    Organization.destroy_all
    User.destroy_all
  end


  desc 'cleaner for all'
  task clean_all_tables: :environment do
    Rake::Task['cleaner:clean_languages'].execute
    Rake::Task['cleaner:set_country_id'].execute
    Rake::Task['cleaner:clean_dup_cities'].execute
    Rake::Task['cleaner:fill_country_id'].execute
    Rake::Task['cleaner:fill_city_id'].execute
    Rake::Task['cleaner:clean_blank_cities_with_exist_countries'].execute
    Rake::Task['cleaner:sector_clean'].execute
    Rake::Task['cleaner:company_size_clean'].execute
    Rake::Task['cleaner:clean_jobs'].execute
    Rake::Task['cleaner:change_admins_to_owner'].execute
    Rake::Task['cleaner:clean_experineces'].execute
    Rake::Task['cleaner:reorder_job_education'].execute
    Rake::Task['cleaner:update_years_of_experience'].execute
    Rake::Task['cleaner:expired_old_jobs'].execute
    Rake::Task['cleaner:deactivate_companies'].execute
    Rake::Task['cleaner:reset_all_primary_keys'].execute
  end
end