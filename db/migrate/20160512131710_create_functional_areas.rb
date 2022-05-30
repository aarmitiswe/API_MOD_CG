class CreateFunctionalAreas < ActiveRecord::Migration
  def change
    create_table :functional_areas do |t|
      t.string :area,  null: false, default: ""
      t.integer :display_order
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end
  end
end
