class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.string :name
      t.text :description
      t.integer :level

      t.references :creator, references: :users
      t.references :parent, references: :folders

      t.timestamps null: false
    end

    add_foreign_key :folders, :users, column: :creator_id
    add_foreign_key :folders, :folders, column: :parent_id
  end
end
