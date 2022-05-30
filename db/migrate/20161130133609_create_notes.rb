class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.references :job_application, index: true, foreign_key: :job_application_id
      t.string :note
      t.references :company_user, index: true, foreign_key: :company_user_id

      t.timestamps null: false
    end
  end
end
