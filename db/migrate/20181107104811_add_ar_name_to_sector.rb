class AddArNameToSector < ActiveRecord::Migration
  def change
    add_column :sectors, :ar_name, :string
  end
end
