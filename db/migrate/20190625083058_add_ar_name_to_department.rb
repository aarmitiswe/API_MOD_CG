class AddArNameToDepartment < ActiveRecord::Migration
  def change
    add_column :departments, :ar_name, :string
  end
end
