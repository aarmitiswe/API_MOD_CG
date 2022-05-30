class AddArNameToCity < ActiveRecord::Migration
  def change
    add_column :cities, :ar_name, :string
  end
end
