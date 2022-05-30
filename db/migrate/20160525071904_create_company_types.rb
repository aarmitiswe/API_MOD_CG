class CreateCompanyTypes < ActiveRecord::Migration
  def change
    create_table :company_types do |t|
      t.string :name
      t.boolean :deleted
      t.boolean :active

      t.timestamps null: false
    end
  end
end
