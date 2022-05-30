class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.string :name,  null: false, default: ""
      t.text :body, null: false, default: ""
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end
  end
end
