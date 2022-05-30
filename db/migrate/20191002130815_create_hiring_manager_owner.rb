class CreateHiringManagerOwner < ActiveRecord::Migration
  def change
    create_table :hiring_manager_owners do |t|
      t.references :user, index: true
      t.references :hiring_manager, index: true
      t.timestamps null: false
    end
    add_foreign_key :hiring_manager_owners, :users
    add_foreign_key :hiring_manager_owners, :hiring_managers
  end
end

