class CreateOffices < ActiveRecord::Migration
  def change
    create_table :offices do |t|
      t.references :company, index: true, foreign_key: true
      t.string :name
      t.string :ar_name
      t.references :country, index: true, foreign_key: true
      t.references :city, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
