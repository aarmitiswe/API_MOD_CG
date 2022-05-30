class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.references :company, index: true, foreign_key: true
      t.string :name
      t.string :ar_name

      t.timestamps null: false
    end
  end
end
