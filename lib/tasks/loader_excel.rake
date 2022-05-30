require "roo"

namespace :loader_excel do

  desc "Load SKILLs"
  task load_position_oracle: :environment do
    xlsx = Roo::Spreadsheet.open('positions_oracle.xlsx')
    puts xlsx.info
    positions_sheet = xlsx.sheet(0)

    (1..positions_sheet.last_row).each do |row_num|
      id_bloovo = positions_sheet.cell('B', col_num)
      id_oracle = positions_sheet.cell('C', col_num)

      position = Position.find_by(id: id_bloovo)
      if position.present? && position.oracle_id.nil?
        if Position.find_by(oracle_id: id_oracle).nil?
          puts "ID BLOOVO: #{id_bloovo} MATCH WITH ORACLE ID: #{id_oracle}"
          position.update_columns(oracle_id: id_oracle)
        else
          puts "ORACLE ID: #{id_oracle} is already exist"
        end
      else
        puts "Position #{id_bloovo} is not exist or  oracle ID already exist"
      end
    end

  end

  desc "Load SKILLs"
  task load_skills: :environment do
    xlsx = Roo::Spreadsheet.open('skills.xlsx')
    puts xlsx.info
    skills_sheet = xlsx.sheet(0)

    (1..skills_sheet.last_row).each do |col_num|
      skill_name = skills_sheet.cell('A', col_num)
      sk = Skill.where('lower(name) = ?', skill_name.downcase).first
      if sk.nil?
        Skill.create(name: skill_name, is_auto_complete: true, weight: 10000)
      else
        sk.update(is_auto_complete: true, weight: 10000, name: skill_name)
      end
    end
    puts "#rows = #{skills_sheet.last_row}"
  end

  desc "Load countries iso"
  task load_iso_countries: :environment do
    xlsx = Roo::Spreadsheet.open('country_list.xlsx')
    puts xlsx.info
    countries_sheet = xlsx.sheet(0)

    (1..countries_sheet.last_row).each do |col_num|
      iso = countries_sheet.cell('A', col_num)
      name = countries_sheet.cell('B', col_num)
      country = Country.find_by_name(name)
      if country.present? && country.iso.nil?
        country.update(iso: iso)
      end
    end
    puts "#rows = #{countries_sheet.last_row}"
  end

  desc "Load lookup nationality"
  task load_lookup_nationality: :environment do
    h={"Fiji"=>"Fijian", "China"=>"Chinese", "Egypt"=>"Egyptian", "Eritrea"=>"Eritrean", "Ethiopia"=>"Ethiopian", "Finland"=>"Finnish", "France"=>"French", "Georgia"=>"Georgian", "Germany"=>"German", "Greece"=>"Greek", "Guinea"=>"Guinean", "Guyana"=>"Guyanese", "Haiti"=>"Haitian", "Honduras"=>"Honduran", "Hong Kong"=>"Hong Kong", "India"=>"Indian", "Iran"=>"Iranian", "Iraq"=>"Iraqi", "Ireland"=>"Irish", "Jamaica"=>"Jamaican", "Japan"=>"Japanese", "Kazakhstan"=>"Kazakhstani", "Kenya"=>"Kenyan", "Kuwait"=>"Kuwaiti", "Latvia"=>"Latvian", "Lebanon"=>"Lebanese", "Libya"=>"Libyan", "Lithuania"=>"Lithuanian", "Macao"=>"Macanese", "Malawi"=>"Malawian", "Mexico"=>"Mexican", "Monaco"=>"Monégasque", "Mongolia"=>"Mongolian", "Morocco"=>"Moroccan", "Myanmar"=>"Burmese", "Nepal"=>"Nepali", "Netherlands"=>"Dutch", "Niger"=>"Nigerien", "Nigeria"=>"Nigerian", "Oman"=>"Omani", "Pakistan"=>"Pakistani", "Palestine"=>"Palestinian", "Paraguay"=>"Paraguayan", "Peru"=>"Peruvian", "Albania"=>"Albanian", "South Korea"=>nil, "Poland"=>"Polish", "Portugal"=>"Portuguese", "Puerto Rico"=>"Puerto Rican", "Qatar"=>"Qatari", "Romania"=>"Romanian", "Russia"=>"Russian", "The Gambia"=>nil, "East Timor"=>nil, "Ivory Coast"=>nil, "Kosovo"=>nil, "North Korea"=>nil, "Andorra"=>"Andorran", "Australia"=>"Australian", "Angola"=>"Angolan", "Austria"=>"Austrian", "Bahamas"=>"Bahamian", "Bahrain"=>"Bahraini", "Bangladesh"=>"Bangladeshi", "Belgium"=>"Belgian", "Benin"=>"Beninese", "Bhutan"=>"Bhutanese", "Bolivia"=>"Bolivian", "Botswana"=>"Motswana", "Brazil"=>"Brazilian", "Burkina Faso"=>"Burkinabé", "Cape Verde"=>"Cabo Verdean", "Cambodia"=>"Cambodian", "Cameroon"=>"Cameroonian", "Namibia"=>"Namibian", "Chad"=>"Chadian", "Chile"=>"Chilean", "Colombia"=>"Colombian", "Democratic Republic of the Congo"=>"Congolese", "Costa Rica"=>"Costa Rican", "Croatia"=>"Croatian", "Cuba"=>"Cuban", "Denmark"=>"Danish", "Djibouti"=>"Djiboutian", "Dominican Republic"=>"Dominican", "Ecuador"=>"Ecuadorian", "Madagascar"=>"Malagasy", "Malaysia"=>"Malaysian", "Mali"=>"Malian", "Malta"=>"Maltese", "Mauritania"=>"Mauritanian", "Rwanda"=>"Rwandan", "Saint Lucia"=>"Saint Lucian", "Saint Vincent and the Grenadines"=>"Saint Vincentian", "Saudi Arabia"=>"Saudi", "Senegal"=>"Senegalese", "Serbia"=>"Serbian", "Seychelles"=>"Seychellois", "Sierra Leone"=>"Sierra Leonean", "Singapore"=>"Singaporean", "Slovakia"=>"Slovak", "Somalia"=>"Somali", "South Africa"=>"South African", "South Sudan"=>"South Sudanese", "Spain"=>"Spanish", "Sri Lanka"=>"Sri Lankan", "Sudan"=>"Sudanese", "Swaziland"=>"Swazi", "Sweden"=>"Swedish", "Switzerland"=>"Swiss", "Syria"=>"Syrian", "Taiwan"=>"Chinese", "Tajikistan"=>"Tajikistani", "Tanzania"=>"Tanzanian", "Thailand"=>"Thai", "Tonga"=>"Tongan", "Trinidad and Tobago"=>"Trinidadian or Tobagonian", "Tunisia"=>"Tunisian", "Turkey"=>"Turkish", "Turkmenistan"=>"Turkmen", "Uganda"=>"Ugandan", "Ukraine"=>"Ukrainian", "United Arab Emirates"=>"Emirati", "United Kingdom"=>"British", "United States"=>"American", "Uruguay"=>"Uruguayan", "Venezuela"=>"Venezuelan", "Vietnam"=>"Vietnamese", "Western Sahara"=>"Sahrawi", "Yemen"=>"Yemeni", "Zambia"=>"Zambian", "Zimbabwe"=>"Zimbabwean", "Afghanistan"=>"Afghan", "Algeria"=>"Algerian", "Argentina"=>"Argentine", "Armenia"=>"Armenian", "Azerbaijan"=>"Azerbaijani", "Barbados"=>"Barbadian", "Belarus"=>"Belarusian", "Belize"=>"Belizean", "Bulgaria"=>"Bulgarian", "Burundi"=>"Burundian", "Canada"=>"Canadian", "Central African Republic"=>"Central African", "Comoros"=>"Comoran", "Republic of the Congo"=>"Congolese", "Czech Republic"=>"Czech", "El Salvador"=>"Salvadoran", "Estonia"=>"Estonian", "Gabon"=>"Gabonese", "Ghana"=>"Ghanaian", "Hungary"=>"Hungarian", "Indonesia"=>"Indonesian", "Italy"=>"Italian", "Jordan"=>"Jordanian", "Liberia"=>"Liberian", "Luxembourg"=>"Luxembourg", "Maldives"=>"Maldivian", "Marshall Islands"=>"Marshallese", "Montenegro"=>"Montenegrin", "Mozambique"=>"Mozambican", "New Zealand"=>"New Zealand", "Norway"=>"Norwegian", "Philippines"=>"Philippine", "Samoa"=>"Samoan", "Bosnia and Herzegovina"=>"Bosnian or Herzegovinian", "Brunei"=>"Bruneian", "Cayman Islands"=>"Caymanian", "Cyprus"=>"Cypriot", "Dominica"=>"Dominican", "Equatorial Guinea"=>"Equatorial Guinean", "Guatemala"=>"Guatemalan", "Guinea-Bissau"=>"Bissau-Guinean", "Iceland"=>"Icelandic", "Kyrgyzstan"=>"Kyrgyzstani", "Laos"=>"Lao", "Macedonia"=>"Macedonian", "Mauritius"=>"Mauritian", "Moldova"=>"Moldovan", "Nicaragua"=>"Nicaraguan", "Panama"=>"Panamanian", "Papua New Guinea"=>"Papua New Guinean", "Saint Kitts and Nevis"=>"Kittitian or Nevisian", "San Marino"=>"Sammarinese", "Slovenia"=>"Slovenian", "Suriname"=>"Surinamese", "Togo"=>"Togolese", "Tuvalu"=>"Tuvaluan", "Uzbekistan"=>"Uzbekistani"}

    h.each do |name, nationality|
      c = Country.find_by_name(name)
      if c.nationality.nil?
        c.update(nationality: nationality)
      end
    end

    xlsx = Roo::Spreadsheet.open('country_list.xlsx')
    puts xlsx.info
    countries_sheet = xlsx.sheet(1)

    (1..countries_sheet.last_row).each do |col_num|
      lookup_code = countries_sheet.cell('A', col_num)
      nationality = countries_sheet.cell('B', col_num)
      country = Country.find_by_nationality(nationality) || Country.find_by_name(nationality)
      if country.present? && country.lookup_nationality.nil?
        country.update(lookup_nationality: lookup_code)
      end
    end
    puts "#rows = #{countries_sheet.last_row}"
  end

end
