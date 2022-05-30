class CreateCompanyLastYearRevenues < ActiveRecord::Migration
  def change
    create_table :company_last_year_revenues do |t|
      t.string :revenue
      t.boolean :deleted
      t.integer :display_order

      t.timestamps null: false
    end
  end
end
