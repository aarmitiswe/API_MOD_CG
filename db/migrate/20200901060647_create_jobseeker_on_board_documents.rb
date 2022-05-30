class CreateJobseekerOnBoardDocuments < ActiveRecord::Migration
  def change
    create_table :jobseeker_on_board_documents do |t|
      t.references :jobseeker, index: true, foreign_key: true
      t.attachment :document
      t.string :type_of_document

      t.timestamps null: false
    end
  end
end
