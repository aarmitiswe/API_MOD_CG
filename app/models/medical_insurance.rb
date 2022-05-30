class MedicalInsurance < ActiveRecord::Base
  belongs_to :jobseeker
  belongs_to :nationality, class_name: Country, foreign_key: 'nationality_id'

  def self.get_medical_insurance file
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    puts xlsx.info
    medical_insurances_sheet = xlsx.sheet(0)

    medical_insurances = []

    (2..medical_insurances_sheet.last_row).each do |col_num|

      english_name = medical_insurances_sheet.cell('A', col_num)
      arabic_name = medical_insurances_sheet.cell('B', col_num)
      birthday = medical_insurances_sheet.cell('C', col_num)
      id_number = medical_insurances_sheet.cell('D', col_num)
      nationality_id = medical_insurances_sheet.cell('E', col_num)
      start_date = medical_insurances_sheet.cell('F', col_num)
      end_date = medical_insurances_sheet.cell('G', col_num)
      relation = medical_insurances_sheet.cell('H', col_num)

      medical_insurances << {
          english_name: english_name, arabic_name: arabic_name, birthday: birthday,
          id_number: id_number, nationality_id: nationality_id, start_date: start_date, end_date: end_date,
          relation: relation
      }
    end
    puts "Medical Insurance is Imported"
    medical_insurances
  end
end
