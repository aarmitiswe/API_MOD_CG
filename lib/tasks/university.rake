require "csv"
require "roo"
require "json"
namespace :university do

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

end