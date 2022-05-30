class CreateJobseekerFolders < ActiveRecord::Migration
  def change
    create_table :jobseeker_folders do |t|
      t.references :jobseeker, index: true, foreign_key: :jobseeker_id
      t.references :folder, index: true, foreign_key: :folder_id

      t.timestamps null: false
    end
  end
end
