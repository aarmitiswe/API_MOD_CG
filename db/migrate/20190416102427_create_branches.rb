class CreateBranches < ActiveRecord::Migration
  def change
    create_table :branches do |t|
      t.string :name
      t.string :ar_name
      t.attachment :avatar
      t.attachment :ar_avatar
      t.references :company, index: true, foreign_key: :company_id

      t.timestamps null: false
    end
  end
end
