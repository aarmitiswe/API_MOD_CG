class CreateCompanyCountries < ActiveRecord::Migration
  def change
    create_table :company_countries do |t|
        t.references :country, index: true
        t.references :company, index: true

        t.timestamps null: false
      end
      add_foreign_key :company_countries, :countries
      add_foreign_key :company_countries, :companies
  end
end
