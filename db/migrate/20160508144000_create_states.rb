class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :name
      t.decimal :latitude, {precision: 10, scale: 6}
      t.decimal :longitude, {precision: 10, scale: 6}
      t.timestamps null: false

      t.references :country, index: true
    end
    add_foreign_key :states, :countries
    add_index :states, :name
  end
end
