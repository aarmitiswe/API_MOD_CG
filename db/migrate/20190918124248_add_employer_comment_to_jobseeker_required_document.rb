class AddEmployerCommentToJobseekerRequiredDocument < ActiveRecord::Migration
  def change
    add_column :jobseeker_required_documents, :employer_comment, :text
  end
end
