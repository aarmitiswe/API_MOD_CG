class AddDepartmentToJob < ActiveRecord::Migration
  def change
    add_reference :jobs, :department, index: true, foreign_key: :department_id
  end
end
