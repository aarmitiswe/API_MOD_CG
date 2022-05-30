class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.string :ar_name
      t.timestamps null: false
    end

    add_column :users, :role_id, :integer
    add_column :users, :assigned_to_organization_level, :boolean, :default => false
  end
end
