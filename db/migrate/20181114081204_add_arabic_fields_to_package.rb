class AddArabicFieldsToPackage < ActiveRecord::Migration
  def change
    add_column :packages, :ar_name, :string
    add_column :packages, :ar_description, :string
    add_column :packages, :ar_details, :text
  end
end
