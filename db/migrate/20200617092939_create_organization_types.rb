class CreateOrganizationTypes < ActiveRecord::Migration
  def change
    create_table :organization_types do |t|
      t.string :name
      t.string :ar_name
      t.integer :order

      t.timestamps null: false
    end
  end
end