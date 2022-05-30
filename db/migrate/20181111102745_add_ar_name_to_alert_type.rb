class AddArNameToAlertType < ActiveRecord::Migration
  def change
    add_column :alert_types, :ar_name, :string
  end
end
