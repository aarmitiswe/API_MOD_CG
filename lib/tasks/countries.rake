namespace :mapper do

  desc 'map countries data'
  task countries: :environment do
    table_name   = 'countries'
    data_records = extract_data(table_name)
    data_records.each do |r|
      country = Country.create({
                                 id:        r[:countryid],
                                 name:      r[:country],
                                 iso:       r[:countryshort],
                                 latitude:  r[:latitude],
                                 longitude: r[:longitude]
                               })
      country.save!
    end
    set_max_ids(table_name)
  end

  desc 'add nationalities to countries'
  task add_nationalities_to_countries: :environment do
    data_records = extract_external_data('countries')

    data_records.each do |r|
      c = Country.find_by_iso(r[:alpha_2_code])
      unless c.nil?
        c.nationality = r[:nationality].split(',').first
        c.save!
      end
    end

  end

  desc 'add missed data from backup of countries'
  task add_countries_backup: :environment do

    data_records = extract_data('countriesbak')

    data_records.each do |r|
      c = Country.find_by_name(r[:country])
      unless c.nil?
        c.iso = r[:countryshort]
        c.latitude = r[:latitude]
        c.longitude = r[:longitude]
        c.save!
      end
    end
  end

  desc 'map states data'
  task states: :environment do
    table_name   = 'states'
    data_records = extract_data(table_name)
    data_records.each do |r|
      state = State.new({
                             id:         r[:stateid],
                             name:       r[:state],
                             country_id: r[:countryid],
                             latitude:   r[:latitude],
                             longitude:  r[:longitude]
                           })
      country = Country.find_by_id(r[:countryid])
      state.save! if country.present?
    end
    set_max_ids(table_name)
  end

  desc 'map cities data'

  task cities: :environment do
    table_name   = 'cities'
    data_records = extract_data(table_name)
    data_records.each do |r|
      city = City.create ({
        id:        r[:cityid],
        name:      r[:city],
        latitude:  r[:latitude],
        longitude: r[:longitude]
      })
      if r[:stateid] && r[:stateid] > 0
        city.state_id = r[:stateid]
        city.country_id = State.find_by_id(r[:stateid]).country_id
      end
      city.save!
    end
    set_max_ids(table_name)
  end

  desc 'map countries geo groups'

  task geo_groups: :environment do
    # create geo groups
    GeoGroup.create([
                      {id: 1, name: 'All Arab Countries'},
                      {id: 2, name: 'All GCC Countries'},
                      {id: 3, name: 'All Anglophone Countries'},
                      {id: 4, name: 'All Eastern European'},
                      {id: 5, name: 'All Western European'},
                      {id: 6, name: 'All Asian Countries'}
                    ]) if GeoGroup.count == 0

    def create_country_geo_record(country_name, geo_group)
      c = Country.find_by_name(country_name)
      CountryGeoGroup.create(country: c, geo_group: geo_group) unless c.nil?
    end

    arab_countries = ["Egypt", "Algeria", "Sudan", "Iraq", "Morocco", "Saudi Arabia", "Yemen", "Syria", "Tunisia", "Somalia", "Jordan", "United Arab Emirates", "Libya", "Palestine", "Lebanon", "Oman", "Kuwait", "Mauritania", "Qatar", "Bahrain"]
    arab_geo_group = GeoGroup.find_by_id(1)
    arab_countries.each { |i| create_country_geo_record(i, arab_geo_group) }

    gcc_countries = ["Bahrain", "Kuwait", "Oman", "Qatar", "Saudi Arabia", "United Arab Emirates"]
    gcc_geo_group = GeoGroup.find_by_id(2)
    gcc_countries.each {|i| create_country_geo_record(i, gcc_geo_group)}

    anglophone_countries = ["Australia", "Bahamas", "Belize", "Canada", "Ireland", "Malta", "Marshall Islands", "Mauritius", "New Zealand", "Mexico", "Papua New Guinea", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "South Africa", "United Kingdom", "United States"]
    anglophone_geo_group = GeoGroup.find_by_id(3)
    anglophone_countries.each { |i| create_country_geo_record(i, anglophone_geo_group) }


    eastern_countries = ["Russia", "Czech Republic", "Poland", "Croatia", "Slovakia", "Hungary", "Romania ", "Serbia", "Lithuania", "Slovenia", "Bulgaria", "Ukraine", "Montenegro", "Albania", "Kosovo", "Macedonia", "Latvia", "Estonia", "Moldova", "Belarus", "Bosnia and Herzegovina"]
    eastern_geo_group = GeoGroup.find_by_id(4)
    eastern_countries.each { |i| create_country_geo_record(i, eastern_geo_group) }

    western_countries = ["Andorra", "Austria", "Belgium", "Denmark", "Finland", "France", "Greece", "Iceland", "Italy ", "Luxembourg", "Macedonia", "Malta", "Monaco", "Netherlands", "Norway", "Portugal", "San Marino", "Slovenia", "Spain", "Sweden", "Switzerland"]
    western_geo_group = GeoGroup.find_by_id(5)
    western_countries.each { |i| create_country_geo_record(i, western_geo_group) }

    asian_countries = ["Afghanistan", "Bangladesh", "Bhutan", "Brunei", "Myanmar", "Cambodia", "China", "India", "Indonesia", "Japan", "North Korea", "South Korea", "Malaysia", "Nepal", "Pakistan", "Philippines", "Singapore", "Sri Lanka", "Thailand"]
    asian_geo_group = GeoGroup.find_by_id(6)
    asian_countries.each { |i| create_country_geo_record(i, asian_geo_group) }
  end


  desc 'map locations data'
  task locations: :environment do
    Rake::Task['mapper:countries'].execute
    Rake::Task['mapper:add_countries_backup'].execute
    Rake::Task['mapper:add_nationalities_to_countries'].execute
    Rake::Task['mapper:states'].execute
    Rake::Task['mapper:cities'].execute
    Rake::Task['mapper:geo_groups'].execute
  end

end
