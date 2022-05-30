class AddArNameToVisaStatus < ActiveRecord::Migration
  def change
    add_column :visa_statuses, :ar_name, :string
  end
end
