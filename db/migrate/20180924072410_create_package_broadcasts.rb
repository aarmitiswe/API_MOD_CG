class CreatePackageBroadcasts < ActiveRecord::Migration
  def change
    create_table :package_broadcasts do |t|
      t.integer :num_credits
      t.float :price
      t.string :currency
      t.text :description

      t.timestamps null: false
    end
  end
end
