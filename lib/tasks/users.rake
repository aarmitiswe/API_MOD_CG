namespace :mapper do
  desc 'map users data from v1 to v2'

  task users: :environment do
    table_name         = 'users'
    options            = { value_converters: {
        createdate:  DateTimeConverter,
        lastupdated: DateTimeConverter,
        lastlogin:   DateTimeConverter,
        isdeleted:   BooleanConverter,
        states:      BooleanConverter,
        dob:         DateConverter,
        usertype:    UserTypeConverter
    } }
    duplicated_records = [1235, 1295, 17311, 21142, 22604, 20823, 12074, 1295, 12105, 26663, 30370]
    data_records       = extract_data(table_name, options)
    data_records.each do |r|
      unless r[:isdeleted] or duplicated_records.include? r[:userid] or !r[:userid]
        user                       = User.new({ id:              r[:userid],
                                                email:           r[:email],
                                                first_name:      r[:firstname],
                                                last_name:       r[:lastname],
                                                created_at:      r[:createdate],
                                                updated_at:      r[:lastupdated],
                                                last_sign_in_at: r[:lastlogin],
                                                active:          r[:status],
                                                deleted:         r[:isdeleted],
                                                role:            r[:usertype],
                                                birthday:       r[:dob] })

        user.country_id            = r[:countryid] if r[:countryid] and r[:countryid] > 0
        user.state_id              = r[:state_id] if r[:stateid] and r[:stateid] > 0
        user.city_id               = r[:location] if r[:location] and r[:location] > 0
        user.profile_image         = r[:imagefile] if r[:imagefile]
        user.gender                = r[:gender]
        user.password              = 'yourAccount@Bl00vo'
        user.password_confirmation = 'yourAccount@Bl00vo'
        user.skip_confirmation!
        user.skip_validation = true
        if user.valid?
          user.save!
        else
          p "invalid user #{user}, errors: #{user.errors.full_messages}"
        end
      end
    end
    set_max_ids(table_name)
  end


  ## TODO: No Need, remove it. temporary task to update users roles
  task update_users_roles: :environment do
    options      = { value_converters: {
        usertype: UserTypeConverter
    } }
    data_records = extract_data('users', options)
    data_records.each do |r|
      u = User.find_by_id(r[:userid])
      unless r[:usertype].nil? or u.nil?
        u.role = r[:usertype]
        u.save!
      end
    end
  end

  desc 'map all user data'
  task users_data: :environment do
    Rake::Task['mapper:users'].execute
  end
end
