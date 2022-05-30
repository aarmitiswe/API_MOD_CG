class AddArNameToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :ar_name, :string
  end
end
