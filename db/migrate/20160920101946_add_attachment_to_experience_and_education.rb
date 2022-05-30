class AddAttachmentToExperienceAndEducation < ActiveRecord::Migration
  def change
    add_column :jobseeker_educations, :attachment, :string
    add_column :jobseeker_experiences, :attachment, :string
  end
end
