class CreateCompanyClassifications < ActiveRecord::Migration
  def change
    create_table :company_classifications do |t|
      t.string :name
      t.boolean :active
      t.boolean :deleted

      t.timestamps null: false
    end
  end
end
