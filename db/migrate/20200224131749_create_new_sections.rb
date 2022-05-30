class CreateNewSections < ActiveRecord::Migration
  def change
    create_table :new_sections do |t|
 	  t.string :name
      t.string :ar_name
      
      t.references :department, index: true, foreign_key: true
	  t.references :unit, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
