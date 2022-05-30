class CreateMedicalInsurances < ActiveRecord::Migration
  def change
    create_table :medical_insurances do |t|
      t.references :jobseeker, index: true, foreign_key: true
      t.string :english_name
      t.string :arabic_name
      t.date :birthday
      t.string :id_number
      t.references :nationality, references: :countries
      t.date :start_date
      t.date :end_date
      t.string :relation

      t.timestamps null: false
    end
    add_foreign_key :medical_insurances, :countries, column: :nationality_id
  end
end
