class CreateJobCategories < ActiveRecord::Migration
  def change
    create_table :job_categories do |t|
      t.string :name,  null: false, default: ""
      t.integer :display_order
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end
  end
end
