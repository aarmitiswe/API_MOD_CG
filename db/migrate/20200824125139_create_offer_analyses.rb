class CreateOfferAnalyses < ActiveRecord::Migration
  def change
    create_table :offer_analyses do |t|
      t.references :job_application, index: true, foreign_key: true
      t.decimal :basic_salary
      t.decimal :housing_allowance
      t.decimal :transportation_allowance
      t.decimal :monthly_salary
      t.decimal :percentage_increase
      t.integer :level

      t.timestamps null: false
    end
  end
end
