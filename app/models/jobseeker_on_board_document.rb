require "roo"

class JobseekerOnBoardDocument < ActiveRecord::Base
  include DocumentUpload

  belongs_to :jobseeker

  DOCUMENT_TYPES = ['nda', 'bank_account', 'medical_insurance', 'personal_picture', 'signed_iban_document',
                    'gosi_certificate', 'employment_certificate', 'retirement_certificate']

  DOCUMENT_TYPES.each {|type| define_method("is_#{type}?") { self.type_of_document == type }}

  # after_create :parse_document
  after_create :move_to_next_boarding_level

  def parse_document
    if self.is_bank_account?
      self.fill_bank_account
    elsif self.is_medical_insurance?
      self.fill_medical_insurance
    end
  end

  def fill_bank_account
    xlsx = Roo::Spreadsheet.open(self.document.url)
    puts xlsx.info
    bank_accounts_sheet = xlsx.sheet(1)

    (2..bank_accounts_sheet.last_row).each do |col_num|
      account_number = bank_accounts_sheet.cell('A', col_num)
      iban_number = bank_accounts_sheet.cell('B', col_num)
      bank_name = bank_accounts_sheet.cell('C', col_num)

      self.jobseeker.bank_accounts.create(account_number: account_number, iban_number: iban_number, bank_name: bank_name)
    end
    puts "Bank Accounts is Imported"
  end

  def fill_medical_insurance
    xlsx = Roo::Spreadsheet.open(self.document.url)
    puts xlsx.info
    medical_insurances_sheet = xlsx.sheet(1)

    (2..medical_insurances_sheet.last_row).each do |col_num|

      english_name = medical_insurances_sheet.cell('A', col_num)
      arabic_name = medical_insurances_sheet.cell('B', col_num)
      birthday = medical_insurances_sheet.cell('C', col_num)
      id_number = medical_insurances_sheet.cell('D', col_num)
      nationality_id = medical_insurances_sheet.cell('E', col_num)
      start_date = medical_insurances_sheet.cell('F', col_num)
      end_date = medical_insurances_sheet.cell('G', col_num)
      relation = medical_insurances_sheet.cell('H', col_num)

      self.jobseeker.medical_insurances.create(english_name: english_name, arabic_name: arabic_name, birthday: birthday,
                                               id_number: id_number, nationality_id: nationality_id,
                                               start_date: start_date, end_date: end_date, relation: relation)
    end
    puts "Medical Insurance is Imported"
  end

  def move_to_next_boarding_level

  end
end
