class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.references :jobseeker, index: true, foreign_key: true
      t.string :account_number
      t.string :iban_number
      t.string :bank_name

      t.timestamps null: false
    end
  end
end
