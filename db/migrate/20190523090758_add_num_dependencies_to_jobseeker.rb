class AddNumDependenciesToJobseeker < ActiveRecord::Migration
  def change
    add_column :jobseekers, :num_dependencies, :integer, default: 0
  end
end
