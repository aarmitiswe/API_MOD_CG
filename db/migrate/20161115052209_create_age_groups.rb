class CreateAgeGroups < ActiveRecord::Migration
  def change
    create_table :age_groups do |t|
      t.integer :min_age
      t.integer :max_age

      t.timestamps null: false
    end
  end
end
