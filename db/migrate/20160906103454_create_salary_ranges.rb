class CreateSalaryRanges < ActiveRecord::Migration
  def change
    create_table :salary_ranges do |t|
      t.integer :salary_from
      t.integer :salary_to

      t.timestamps null: false
    end
  end
end
