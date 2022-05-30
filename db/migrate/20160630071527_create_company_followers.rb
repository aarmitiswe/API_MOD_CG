class CreateCompanyFollowers < ActiveRecord::Migration
  def change
    create_table :company_followers do |t|
      t.references :company
      t.references :user

      t.timestamps null: false
    end
    add_foreign_key :company_followers, :companies
    add_foreign_key :company_followers, :users
  end
end
