class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name
      t.decimal :latitude, {precision: 10, scale: 6}
      t.decimal :longitude, {precision: 10, scale: 6}

      t.references :state, index: true

      t.timestamps null: false
    end
    add_foreign_key :cities, :states
    add_index :cities, :name
  end
end
