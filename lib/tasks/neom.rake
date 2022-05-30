require "csv"
require "roo"
require "json"
namespace :neom do

  EXTERNAL_CSV_FOLDER = "external_csv"

  desc "import universities"
  task :import_universities, [:sheet_num, :field_name] => [:environment] do |t, args|
    sheet_num =  args[:sheet_num].to_i
    field_name = args[:field_name]


    workbook = Roo::Excelx.new("#{EXTERNAL_CSV_FOLDER}/neom_universities.xlsx")
    workbook.default_sheet = workbook.sheets[sheet_num]
    headers = Hash.new
    workbook.row(1).each_with_index {|header,i|
      headers[header] = i
    }

    ((workbook.first_row + 1)..workbook.last_row).each do |row|
      # Get the column data using the column heading.
      university_name = workbook.row(row)[headers[field_name]]
      country_name = workbook.row(row)[headers["Country"]]
      university = University.find_by_name(university_name.strip)

      if !university.present?
        University.create(name: university_name)
        print "Added Universities: #{university_name}\n\n"
      else
        university.update(country_id: Country.find_by_name(country_name).try(:id))
        print "Update Country for: #{university_name}\n\n"
      end

    end


    puts "University is Imported"
  end

  desc "create graduate program job"
  task :create_graduate_program_job  => [:environment] do |t, args|
    job = Job.find_by_title('graduate_program')
    if !job.present?
      Job.create(title: 'graduate_program', start_date: Date.today, end_date: 100.years.from_now,
                 company_id: Company.first.id, country_id: Country.find_by_name('Saudi Arabia').id,
                 city_id: City.find_by_name('Tabuk').id,
                 job_status_id: JobStatus.find_by_status('Open').id,
                 deleted: true,
                 description: 'Gradruade Program', job_type_id: JobType.first.id,
                 sector_id: Company.first.sector_id, functional_area_id: FunctionalArea.first.id,
                 job_education_id: JobEducation.first.id, experience_from: 0, experience_to: 2,
                 job_experience_level_id: JobExperienceLevel.first.id, marital_status: 'any', requirements: 'any')
      puts "Created"
    else
      job.update(title: 'graduate_program', start_date: Date.today, end_date: 100.years.from_now,
                 company_id: Company.first.id, country_id: Country.find_by_name('Saudi Arabia').id,
                 city_id: City.find_by_name('Tabuk').id,
                 job_status_id: JobStatus.find_by_status('Open').id,
                 deleted: true,
                 description: 'Gradruade Program', job_type_id: JobType.first.id,
                 sector_id: Company.first.sector_id, functional_area_id: FunctionalArea.first.id,
                 job_education_id: JobEducation.first.id, experience_from: 0, experience_to: 2,
                 job_experience_level_id: JobExperienceLevel.first.id, marital_status: 'any', requirements: 'any')
      puts "Updated"
    end
    puts "End graduation program job done"
  end


  desc "Add Benefits"
  task :add_benefits  => [:environment] do |t, args|

       new_benefitList = [
        {
        name: "Performance bonus plan",
        icon: "zmdi zmdi-money-box",
        ar_name: "خطة مكافأة الأداء"
        },
        {
        name: "Long term incentives",
        icon: "zmdi zmdi-bookmark",
        ar_name: "حوافز طويلة الأجل"
        },
        {
        name: "Housing allowance",
        icon: "zmdi zmdi-home",
        ar_name: "بدل سكن"
        },
        {
        name: "Transportation allowance",
        icon: "zmdi zmdi-car-taxi",
        ar_name: "بدل النقل"
        },
        {
        name: "Relocation allowance",
        icon: "zmdi zmdi-truck",
        ar_name: "بدل الانتقال"
        },
        {
        name: "Savings plan",
        icon: "zmdi zmdi-inbox",
        ar_name: "خطة الادخار"
        },
        {
        name: "Education allowance",
        icon: "zmdi zmdi-graduation-cap",
        ar_name: "بدل التعليم"
        },
        {
        name: "30 days annual leave",
        icon: "zmdi zmdi-airline-seat-recline-extra",
        ar_name: "30 يوم إجازة سنوية"
        },
        {
        name: "Mobile allowance",
        icon: "zmdi zmdi-smartphone-android",
        ar_name: "بدل المحمول"
        },
        {
        name: "Visiting tickets for overseas based dependents",
        icon: "icon-travel",
        ar_name: "زيارة تذاكر المعالين في الخارج"
        },
        {
        name: "Life insurance",
        icon: "zmdi zmdi-walk",
        ar_name: "زيارة تذاكر المعالين في الخارج"
        },
        {
        name: "Free campus accommodation",
        icon: "zmdi zmdi-city",
        ar_name: "الحرم الجامعي السكن"
        }
       ]

       new_benefitList.each do |sel_benefit|
         if found_benefit = Benefit.find_by_name(sel_benefit[:name])
           puts "Updating #{sel_benefit[:name]}"
           found_benefit.update(sel_benefit)
         else
           puts "Creating #{sel_benefit[:name]}"
           Benefit.create(sel_benefit)
         end
       end
      puts "Done"
  end


end