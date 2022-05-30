class RemoveSalaryAndAgeFromJob < ActiveRecord::Migration
  def change
    remove_column :jobs, :salary_from, :float
    remove_column :jobs, :salary_to, :float
    remove_column :jobs, :age_range, :string
  end
end
