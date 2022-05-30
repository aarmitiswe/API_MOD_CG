class JobseekerCoverletter < ActiveRecord::Migration
  def change
    create_table :jobseeker_coverletters do |t|
      t.references :jobseeker, index: true
      t.string :title
      t.string :file_path
      t.string :description
      t.boolean :default

      t.timestamps null: false
    end
    add_foreign_key :jobseeker_coverletters , :jobseekers
  end
end
