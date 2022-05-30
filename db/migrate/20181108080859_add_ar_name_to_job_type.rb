class AddArNameToJobType < ActiveRecord::Migration
  def change
    add_column :job_types, :ar_name, :string
  end
end
