class CreateAssignedFolders < ActiveRecord::Migration
  def change
    create_table :assigned_folders do |t|
      t.references :user, index: true, foreign_key: :user_id
      t.references :folder, index: true, foreign_key: :folder_id

      t.timestamps null: false
    end
  end
end
