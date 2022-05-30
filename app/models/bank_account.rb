class BankAccount < ActiveRecord::Base
  belongs_to :jobseeker

  def self.get_bank_account file
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    puts xlsx.info
    bank_accounts_sheet = xlsx.sheet(0)

    bank_accounts = []

    (2..bank_accounts_sheet.last_row).each do |col_num|
      account_number = bank_accounts_sheet.cell('A', col_num)
      iban_number = bank_accounts_sheet.cell('B', col_num)
      bank_name = bank_accounts_sheet.cell('C', col_num)

      bank_accounts << {
          account_number: account_number, iban_number: iban_number, bank_name: bank_name
      }
    end
    puts "Bank Accounts is Imported"
    bank_accounts
  end
end
