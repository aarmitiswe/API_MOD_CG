class ChangeIdNumberToNewFromJobseeker < ActiveRecord::Migration
  def change
    change_column :jobseekers, :id_number, :string
  end
end
