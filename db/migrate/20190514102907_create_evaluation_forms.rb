class CreateEvaluationForms < ActiveRecord::Migration
  def change
    create_table :evaluation_forms do |t|
      t.string :name
      t.string :ar_name

      t.timestamps null: false
    end
  end
end
