class CreateJobTypes < ActiveRecord::Migration
  def change
    create_table :job_types do |t|
      t.string :name,  null: false, default: ""
      t.integer :display_order
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end
  end
end
