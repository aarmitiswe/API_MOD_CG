class CreateCompanySizes < ActiveRecord::Migration
  def change
    create_table :company_sizes do |t|
      t.string :size
      t.integer :display_order
      t.boolean :deleted, default: false
      t.boolean :active, default: false

      t.timestamps null: false
    end
  end
end
