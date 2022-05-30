class AddDeletedToHiringManager < ActiveRecord::Migration
  def change
    add_column :hiring_managers, :deleted, :boolean, default: false
  end
end
