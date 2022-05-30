class CreateCareerFairs < ActiveRecord::Migration
  def change
    create_table :career_fairs do |t|
      t.string :title
      t.string :logo_image
      t.references :country, index: true, foreign_key: true
      t.integer :country_id
      t.references :city, index: true, foreign_key: true
      t.integer :city_id
      t.string :address
      t.boolean :active, default: true
      t.integer :gender
      t.timestamps null: false
    end
  end
end
