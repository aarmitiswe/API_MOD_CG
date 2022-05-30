class AddFlagsToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_hiring_manager, :boolean
  end
end
