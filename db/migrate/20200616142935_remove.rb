class Remove < ActiveRecord::Migration
  def change
    remove_column :users, :role
  end
end
