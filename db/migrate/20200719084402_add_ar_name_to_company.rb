class AddArNameToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :ar_name, :string
  end
end
