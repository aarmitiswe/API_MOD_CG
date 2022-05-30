class AddLockIdToPosition < ActiveRecord::Migration
  def change
    add_column :positions, :lock_code, :string
  end
end
