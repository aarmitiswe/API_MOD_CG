class CreateSavedJobSearches < ActiveRecord::Migration
  def change
    create_table :saved_job_searches do |t|
      t.references :jobseeker, index: true, foreign_key: :jobseeker_id
      t.references :alert_type, index: true, foreign_key: :alert_type_id
      t.string :title
      t.string :api_url
      t.string :web_url

      t.timestamps null: false
    end
  end
end
