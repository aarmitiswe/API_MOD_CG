class AddEmploymentTypeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :employment_type, :string
  end
end
