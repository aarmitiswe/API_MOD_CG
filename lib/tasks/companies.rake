namespace :mapper do

  desc 'map company_size data'

  task company_size: :environment do
    table_name = 'company_sizes'
    records    = extract_data('companysize')
    records.each do |r|
      unless r[:displayorder].nil?
        record = CompanySize.create({id:            r[:id],
                                     size:          r[:employercount],
                                     display_order: r[:displayorder],
                                     deleted:       r[:deletestatus]})
        r[:deletestatus].nil? ? record.deleted = true : record.deleted = false
        record.deleted ? record.active = false : record.active = true
        record.save!
      end

    end
    set_max_ids(table_name)
  end

  desc 'map company_type data'

  task company_type: :environment do
    table_name = 'company_types'
    records    = extract_data('companytype')
    records.each do |r|
      if r[:status] == 't' and r[:deletestatus] == 'f'
        record = CompanyType.create({id:      r[:companytypeid],
                                     name:    r[:companytypename],
                                     active:  r[:status],
                                     deleted: r[:deletestatus]})
        r[:deletestatus].nil? ? record.deleted = true : record.deleted = false
        record.save!
      end
    end
    set_max_ids(table_name)
  end

  desc 'map company_classification data'

  task company_classification: :environment do
    table_name = 'company_classifications'
    records    = extract_data('companyclassification')
    records.each do |r|
      if r[:status] == 't' and r[:deletestatus] == 'f'
        record = CompanyClassification.create({id:      r[:companyclassificationid],
                                               name:    r[:companyclassificationname],
                                               active:  r[:status],
                                               deleted: r[:deletestatus]})
        r[:deletestatus].nil? ? record.deleted = true : record.deleted = false
        record.save!
      end
    end
    set_max_ids(table_name)
  end


  desc 'map company_last_revenue data'

  task company_last_revenue: :environment do
    table_name     = 'lastyearrevenue'
    new_table_name = 'company_last_year_revenues'
    data_records   = extract_data(table_name)
    data_records.each do |r|
      unless r[:deletestatus] == 't'
        revenue = CompanyLastYearRevenue.create({revenue:       r[:lastyearrevenue],
                                                 id:            r[:lastyearrevenueid],
                                                 display_order: r[:displayorder]})
        revenue.save!
      end
    end
    set_max_ids(new_table_name)
  end


  desc 'map companies information'

  task companies_info: :environment do
    reset_table_ids('companies')
    reset_table_ids('company_countries')
    reset_table_ids('company_users')
    options                  = {value_converters: {
      userdetailsfieldsid: UserDetailsFieldsConverter,
    }}
    users                    = User.where(role: 'company_owner').order('id')
    user_details_values      = extract_data('userdetailsvalues', options)
    companies_countries_data = extract_data('companygeographicalpresence')
    old_users_data           = extract_data('users')
    users.each do |u|
      user_selected_data = user_details_values.select { |v| v[:userid] == u.id }
      countries          = companies_countries_data.select { |v| v[:userid] == u.id }
      company_data       = {user_id: u.id}
      company_users      = old_users_data.select { |v| v[:userid] == u.id || v[:parentuserid] == u.id }
      user_selected_data.each do |d|
        unless d[:userdetailsselected].nil? or d[:userdetailsselected] == 0 or d[:userdetailsfieldsid].nil?
          company_data[d[:userdetailsfieldsid]] = d[:userdetailsselected]
        end
      end

      company = Company.new({name:                      u.first_name,
                             summary:                   company_data[:company_summary],
                             establishment_date:        u.birthday,
                             website:                   company_data[:website],
                             profile_image:             company_data[:profile_image_file],
                             current_city_id:           company_data[:current_city_id],
                             address_line1:             company_data[:address_line1],
                             address_line2:             company_data[:address_line2],
                             phone:                     company_data[:mobile_phone],
                             fax:                       company_data[:fax],
                             contact_email:             company_data[:company_email],
                             po_box:                    company_data[:zip],
                             google_plus_page_url:      company_data[:google_plus_page_url],
                             linkedin_page_url:         company_data[:linkedin_page_url],
                             facebook_page_url:         company_data[:facebook_page_url],
                             twitter_page_url:          company_data[:twitter_page_url],
                             sector_id:                 company_data[:company_industry],
                             company_size_id:           company_data[:no_of_employees],
                             company_type_id:           company_data[:company_type],
                             contact_person:            company_data[:contact_person],
                             company_classification_id: company_data[:company_classification],
                             current_country_id:        u.country_id,
                             city_id:                   u.city_id,
                             country_id:                u.country_id,
                             active:                    u.active,
                             deleted:                   u.deleted,
                             created_at:                u.created_at,
                             updated_at:                u.updated_at
                            })
      if company.save!
        countries.each do |c|
          next if c[:countryid].nil? || c[:countryid].zero?
          CompanyCountry.create({company_id: company.id, country_id: c[:countryid]})
        end
        company_users.each do |i|
          company_user = User.find_by_id(i[:userid])
          CompanyUser.create({user: company_user, company: company}) unless company_user.nil?
        end
      end
    end
  end

  desc 'map companies followers'
  task companies_followers: :environment do
    table_name = 'company_followers'
    options    = {value_converters: {
      startedfollowingat: DateTimeConverter,
    }}
    records    = extract_data('companyfollowers', options)
    records.each do |r|
      user      = User.find_by_id(r[:userid])
      jobseeker = user.try(:jobseeker)
      company   = User.find_by_id(r[:companyprofileid]).try(:companies).try(:first)
      unless jobseeker.nil? or company.nil?
        record = CompanyFollower.new({id:           r[:companyfollowersid],
                                      jobseeker_id: jobseeker.id,
                                      company_id:   company.id,
                                      created_at:   r[:startedfollowingat],
                                      updated_at:   r[:startedfollowingat]})
        unless record.save
          puts "Error #{record.jobseeker_id} & #{record.company_id}    #{record.errors.full_messages}"
        end
      end
    end
    set_max_ids(table_name)
  end

  # TODO: Remove this task, after make sure deployment stable, just for migrate current_date to use jobseeker instead of user
  desc 'map companies with jobseekers instead of users'
  task add_jobseeker_to_company_followers: :environment do
    CompanyFollower.all.each do |company_follower|
      next if !company_follower.user || !company_follower.user.jobseeker
      company_follower.update_attribute(:jobseeker_id, company_follower.user.jobseeker.id)
    end
    CompanyFollower.where(jobseeker_id: nil).destroy_all
  end

  desc 'map companies_data data'
  task companies_data: :environment do
    Rake::Task['mapper:company_size'].execute
    Rake::Task['mapper:company_type'].execute
    Rake::Task['mapper:company_classification'].execute
    Rake::Task['mapper:company_last_revenue'].execute
    Rake::Task['mapper:companies_info'].execute
  end
end
