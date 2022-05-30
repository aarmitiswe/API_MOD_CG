class CreateHashTags < ActiveRecord::Migration
  def change
    create_table :hash_tags do |t|
      t.string :name

      t.timestamps null: false
    end
    add_index :hash_tags, :name, unique: true
  end
end
