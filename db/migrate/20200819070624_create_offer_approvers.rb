class CreateOfferApprovers < ActiveRecord::Migration
  def change
    create_table :offer_approvers do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :level

      t.timestamps null: false
    end
  end
end
