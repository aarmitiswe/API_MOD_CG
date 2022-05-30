class JobseekerResume < ActiveRecord::Migration
  def change
    create_table :jobseeker_resumes do |t|
      t.references :jobseeker, index: true
      t.string :title
      t.string :file_path
      t.boolean :default

      t.timestamps null: false
    end
    add_foreign_key :jobseeker_resumes, :jobseekers
  end
end
