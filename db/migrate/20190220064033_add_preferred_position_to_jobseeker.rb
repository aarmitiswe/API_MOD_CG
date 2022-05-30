class AddPreferredPositionToJobseeker < ActiveRecord::Migration
  def change
    add_column :jobseekers, :preferred_position, :string
  end
end
