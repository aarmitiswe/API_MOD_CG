class AddArNameToCompanyType < ActiveRecord::Migration
  def change
    add_column :company_types, :ar_name, :string
  end
end
