class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.references :user, index: true, foreign_key: :user_id
      t.string :controller_name
      t.string :action
      t.string :name

      t.timestamps null: false
    end
  end
end
