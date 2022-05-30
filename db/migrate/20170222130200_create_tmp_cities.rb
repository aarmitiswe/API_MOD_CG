class CreateTmpCities < ActiveRecord::Migration
  def change
    create_table :tmp_cities do |t|
      t.string :name
      t.integer :country_id
      t.string :country_name

      t.timestamps null: false
    end
  end
end
