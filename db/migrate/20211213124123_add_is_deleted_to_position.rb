class AddIsDeletedToPosition < ActiveRecord::Migration
  def change
    add_column :positions, :is_deleted, :boolean, default: false
  end
end
