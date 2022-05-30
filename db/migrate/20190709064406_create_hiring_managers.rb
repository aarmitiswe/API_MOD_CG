class CreateHiringManagers < ActiveRecord::Migration
  def change
    create_table :hiring_managers do |t|
      t.references :section, index: true, foreign_key: :section_id
      t.references :office, index: true, foreign_key: :office_id
      t.references :department, index: true, foreign_key: :department_id
      t.references :unit, index: true, foreign_key: :unit_id
      t.references :grade, index: true, foreign_key: :grade_id
      t.references :approver_one, references: :users
      t.references :approver_two, references: :users
      t.references :approver_three, references: :users
      t.references :approver_four, references: :users
      t.references :approver_five, references: :users

      t.timestamps null: false
    end

    add_foreign_key :hiring_managers, :users, column: :approver_one_id
    add_foreign_key :hiring_managers, :users, column: :approver_two_id
    add_foreign_key :hiring_managers, :users, column: :approver_three_id
    add_foreign_key :hiring_managers, :users, column: :approver_four_id
    add_foreign_key :hiring_managers, :users, column: :approver_five_id
  end
end
