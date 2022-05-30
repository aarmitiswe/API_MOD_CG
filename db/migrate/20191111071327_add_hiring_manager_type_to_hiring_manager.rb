class AddHiringManagerTypeToHiringManager < ActiveRecord::Migration
  def change
    add_column :hiring_managers, :hiring_manager_type, :string, default: "job"
  end
end
