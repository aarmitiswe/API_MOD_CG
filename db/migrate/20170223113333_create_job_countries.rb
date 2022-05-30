class CreateJobCountries < ActiveRecord::Migration
  def change
    create_table :job_countries do |t|
      t.references :job, index: true, foreign_key: :job_id
      t.references :country, index: true, foreign_key: :country_id

      t.timestamps null: false
    end
  end
end
