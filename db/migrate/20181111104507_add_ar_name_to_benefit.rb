class AddArNameToBenefit < ActiveRecord::Migration
  def change
    add_column :benefits, :ar_name, :string
  end
end
