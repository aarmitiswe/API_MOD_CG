class AddNationalityIdAttachmentToJobseeker < ActiveRecord::Migration
  def change
    add_attachment :jobseekers, :document_nationality_id
    add_column :jobseekers, :nationality_id_number, :string
  end
end
