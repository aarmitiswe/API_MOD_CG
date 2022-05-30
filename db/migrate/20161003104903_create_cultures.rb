class CreateCultures < ActiveRecord::Migration
  def change
    create_table :cultures do |t|
      t.string :title
      t.attachment :avatar
      t.references :company, index: true, foreign_key: :company_id

      t.timestamps null: false
    end
  end
end
