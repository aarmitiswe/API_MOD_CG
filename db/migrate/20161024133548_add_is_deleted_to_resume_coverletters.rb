class AddIsDeletedToResumeCoverletters < ActiveRecord::Migration
  def change
    add_column :jobseeker_resumes, :is_deleted, :boolean
    add_column :jobseeker_coverletters, :is_deleted, :boolean
  end
end
