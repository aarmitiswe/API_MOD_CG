class AddTotalEmployeesToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :total_male_employees, :integer
    add_column :companies, :total_female_employees, :integer
  end
end
