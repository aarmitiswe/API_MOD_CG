class CreateCompanyUsers < ActiveRecord::Migration
  def change
    create_table :company_users do |t|
      t.references :user, index: true
      t.references :company, index: true

      t.timestamps null: false
    end
    add_foreign_key :company_users, :users
    add_foreign_key :company_users, :companies
  end
end
