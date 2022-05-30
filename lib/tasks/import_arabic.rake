require "csv"
require "roo"
require "json"

namespace :import_arabic do

  CSV_ARABIC_FOLDER = "arabic_translate"

  desc 'import arabic tables from files'
  task :general_table_by_name, [:table_name, :field_name] => [:environment] do |t, args|
    table_name = args[0][:table_name]
    field_name = args[0][:field_name]

    CSV.open("#{CSV_ARABIC_FOLDER}/#{table_name.pluralize}.csv", 'r', {encoding: 'UTF-8'}).to_a.each_with_index do |row_arr, index|
      if index > 0
        # This "\u00A0" is hex code for Non-breaking space
        object = table_name.camelize.constantize.find_by("#{field_name} = ?", row_arr[1].gsub("\u00A0", " ").strip)
        object.update({"ar_#{field_name}" => row_arr[2].gsub("\u00A0", " ").strip}) if object.present? && row_arr[2].present?
      end
    end

    puts "#{table_name.camelize} is Imported"
  end

  desc "import arabic packages"
  task :import_packages_arabic, [:sheet_num, :field_name] => [:environment] do |t, args|
    sheet_num =  args[0][:sheet_num].to_i
    field_name =  args[0][:field_name]

    xlsx = Roo::Spreadsheet.open("#{CSV_ARABIC_FOLDER}/packages.xlsx")
    puts xlsx.info
    packages_sheet = xlsx.sheet(sheet_num)

    (2..packages_sheet.last_row).each do |col_num|
      package_name = packages_sheet.cell('A', col_num)
      new_val = packages_sheet.cell('C', col_num)
      package = Package.where('name = ?', package_name).first

      package.update({"ar_#{field_name}" => new_val.gsub("\u00A0", " ").strip}) if package.present? && package.send("ar_#{field_name}").blank? && new_val.present?
    end
    puts "Packages is Imported"
  end

  desc "import arabic sectors"
  task import_sectors_arabic: :environment do
    # row_arr = [" Id", "Name", " Arabic Name"]
    CSV.open("#{CSV_ARABIC_FOLDER}/sectors.csv", 'r', {encoding: 'UTF-8'}).to_a.each_with_index do |row_arr, index|
      if index > 0
        # This "\u00A0" is hex code for Non-breaking space
        sector = Sector.find_by_name(row_arr[1].gsub("\u00A0", " ").strip)
        sector.update(ar_name: row_arr[2].gsub("\u00A0", " ").strip) if sector.present?
      end
    end
    puts "Sectors is Imported"
  end

  desc "import arabic languages"
  task import_languages_arabic: :environment do
    # row_arr = [" Id", "Name", " Arabic Name"]
    CSV.open("#{CSV_ARABIC_FOLDER}/languages.csv", 'r', {encoding: 'UTF-8'}).to_a.each_with_index do |row_arr, index|
      if index > 0
        # This "\u00A0" is hex code for Non-breaking space
        language = Language.find_by_name(row_arr[1].gsub("\u00A0", " ").strip)
        language.update(ar_name: row_arr[2].gsub("\u00A0", " ").strip) if language.present?
      end
    end
    puts "Languages is Imported"
  end

  desc "import arabic job_experience_levels"
  task import_job_experience_levels_arabic: :environment do
    # row_arr = [" Id", "Name", " Arabic Name"]
    CSV.open("#{CSV_ARABIC_FOLDER}/job_experience_levels.csv", 'r', {encoding: 'UTF-8'}).to_a.each_with_index do |row_arr, index|
      if index > 0
        # This "\u00A0" is hex code for Non-breaking space
        job_experience_level = JobExperienceLevel.find_by_level(row_arr[1].gsub("\u00A0", " ").strip)
        job_experience_level.update(ar_level: row_arr[2].gsub("\u00A0", " ").strip) if job_experience_level.present?
      end
    end
    puts "JobExperienceLevel is Imported"
  end

  desc "import arabic job_educations"
  task import_job_educations_arabic: :environment do
    # row_arr = [" Id", "Name", " Arabic Name"]
    CSV.open("#{CSV_ARABIC_FOLDER}/job_educations.csv", 'r', {encoding: 'UTF-8'}).to_a.each_with_index do |row_arr, index|
      if index > 0
        # This "\u00A0" is hex code for Non-breaking space
        job_education = JobEducation.find_by_level(row_arr[1].gsub("\u00A0", " ").strip)
        job_education.update(ar_level: row_arr[2].gsub("\u00A0", " ").strip) if job_education.present?
      end
    end
    puts "JobEducation is Imported"
  end

  desc "Generate Arabic Hash for Algolia Result"
  task :generate_arabic_hash, [:table_name, :field_name] => [:environment] do |t, args|
    table_name = args[0][:table_name]
    field_name = args[0][:field_name]

    tableHash = {}
    table_name.camelize.constantize.all.each do |object|
      tableHash[object.send(field_name)] = object.send("ar_#{field_name}")
    end

    # Write JSON File
    File.open("public/algolia_translate/#{table_name}_hash.json","w") do |f|
      f.write(tableHash.to_json)
    end
    puts "#{table_name} hash is ready"
  end

  desc "Special City"
  task translate_special_city: :environment do
    list_city_name = {"Aparecida de Goiânia": "أباريسيدا دي جويانيا", "Belém": "بيليم",
                      "Florianópolis": "فلوريانوبوليس", "Ribeirão Preto": "ريبيراو بريتو", "Tai’an": "تايآن",
                      "Ürümqi": "أورومتشي", "Xi’an": "شيان", "Düsseldorf": "دوسلدورف",
                      "Köln": "كولونيا", "Nürnberg": "نورنبرغ", "Mişratah": "مصراتة",
                      "Tripoli": "طرابلس", "George Town": "جورج تاون",
                      "Tonalá": "تونالا","Tuxtla Gutiérrez": "توكستلا جوتيريز",
                      "Hyderabad": "حيدر أباد", "San Juan": "سان خوان",
                      "Orël": "أوريل", "Ryazan'": "ريازان", "Newcastle": "نيوكاسل", "Córdoba": "قرطبة",
                      "Ataşehir": "أتاسهير", "Bağcılar": "باجشيلار", "Bahçelievler": "باهسيليفر",
                      "Çankaya": "كانكايا", "Diyarbakır": "ديار بكر", "Eskişehir": "اسكي شهير",
                      "Kahramanmaraş": "قهرمان", "Karabağlar": "كاراباجلار",
                      "Muratpaşa": "موراتباسا", "Şanlıurfa": "شانلي اورفا", "Şişli": "سيسلي",
                      "Üsküdar": "أوسكودار", "Khmel'nyts'kyy": "خيميل نيسكي", "London": "لندن", "Barcelona": "برشلونة",
                      "Ciudad Bolívar": "سيوداد بوليفار", "Maturín": "ماتورين", "Mérida": "ميريدا",
                      "Valencia": "فالنسيا", "Biên Hòa": "بين هوا", "Ta'izz": "تعز", "Peć": "بي",
                      "Deçan": "ديكان", "Vučitrn": "فوتشيتم", "Bakau": "باكو", "Banjul": "بانجول",
                      "Bansang": "بانسانغ", "Basse Santa Su": "باس سانتا سو", "Brikama": "بريكاما",
                      "Brufut": "مدينة بروفوت","Farafenni": "فارافيني",
                      "Janjanbureh (Georgetown)": "جانيانبورة (جورج تاون)", "Jufureh": "الجفورة", "Kalagi": "كالاجي",
                      "Kanilai": "كانيلاي","Kerewan": "كيريوان", "Kololi": "كولولي", "Kuntaur": "كونتور",
                      "Lamin (North Bank Division)": "لامين (قسم الضفة الشمالية)",
                      "Lamin (Western Division)": "لامين (القسم الغربي)", "Mansa Konko": "مانسا كونكو",
                      "Nema Kunku": "نيما كونكو", "Serekunda": "سيريكوندا", "Soma": "سوما",
                      "Sukuta": "سوكوتا", "Tanji": "طنجي", "Goa": "غوا", "Gadsden": "غادسدن"}





    # City.where(ar_name: nil).each do |city|
    #   new_name_ar = list_city_name[city.name]
    #   city.update(ar_name: new_name_ar) if new_name_ar.present?
    # end

    list_city_name.each do |key, val|
      city = City.where(ar_name: nil).find_by_name(key)
      if city
        city.update(ar_name: val)
      else
        puts key
      end
    end
  end

  desc "import arabic for all tables"
  task import_all_tables_arabic: :environment do
    Rake::Task['import_arabic:general_table_by_name'].execute([table_name: "sector", field_name: "name"])
    Rake::Task['import_arabic:general_table_by_name'].execute([table_name: "language", field_name: "name"])
    Rake::Task['import_arabic:general_table_by_name'].execute([table_name: "job_experience_level", field_name: "level"])
    Rake::Task['import_arabic:general_table_by_name'].execute([table_name: "job_education", field_name: "level"])
    Rake::Task['import_arabic:general_table_by_name'].execute([table_name: "job_status", field_name: "status"])
    Rake::Task['import_arabic:general_table_by_name'].execute([table_name: "visa_status", field_name: "name"])
    Rake::Task['import_arabic:general_table_by_name'].execute([table_name: "job_type", field_name: "name"])
    Rake::Task['import_arabic:general_table_by_name'].execute([table_name: "functional_area", field_name: "area"])
    Rake::Task['import_arabic:general_table_by_name'].execute([table_name: "alert_type", field_name: "name"])
    Rake::Task['import_arabic:general_table_by_name'].execute([table_name: "benefit", field_name: "name"])
    Rake::Task['import_arabic:general_table_by_name'].execute([table_name: "company_classification", field_name: "name"])
    Rake::Task['import_arabic:general_table_by_name'].execute([table_name: "company_type", field_name: "name"])
    Rake::Task['import_arabic:general_table_by_name'].execute([table_name: "city", field_name: "name"])
    Rake::Task['import_arabic:general_table_by_name'].execute([table_name: "country", field_name: "name"])
    Rake::Task['import_arabic:general_table_by_name'].execute([table_name: "job_application_status", field_name: "status"])
    Rake::Task['import_arabic:import_packages_arabic'].execute([sheet_num: 0, field_name: "name"])
    Rake::Task['import_arabic:import_packages_arabic'].execute([sheet_num: 1, field_name: "description"])
    Rake::Task['import_arabic:import_packages_arabic'].execute([sheet_num: 2, field_name: "details"])
  end

  desc "Generate Hash for Some Tables"
  task generate_arabic_hash_for_three_tables: :environment do
    # Rake::Task['import_arabic:generate_arabic_hash'].execute([table_name: "country", field_name: "name"])
    # Rake::Task['import_arabic:generate_arabic_hash'].execute([table_name: "city", field_name: "name"])
    # Rake::Task['import_arabic:generate_arabic_hash'].execute([table_name: "sector", field_name: "name"])
    Rake::Task['import_arabic:generate_arabic_hash'].execute([table_name: "job_education", field_name: "level"])
  end
end