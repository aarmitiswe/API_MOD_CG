class AddColumnsToJob < ActiveRecord::Migration
  def change
    add_reference :jobs, :age_group, index: true, foreign_key: :age_group_id
    add_reference :jobs, :salary_range, index: true, foreign_key: :salary_range_id
  end
end
