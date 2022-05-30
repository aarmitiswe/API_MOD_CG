class CreateUniversities < ActiveRecord::Migration
  def change
    create_table :universities do |t|
      t.string :name
      t.references :country, index: true, foreign_key: :country_id

      t.timestamps null: false
    end
  end
end
