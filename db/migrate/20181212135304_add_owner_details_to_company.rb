class AddOwnerDetailsToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :owner_name, :string
    add_column :companies, :owner_designation, :string
  end
end
