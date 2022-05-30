class CreateApiV1EventVisitors < ActiveRecord::Migration
  def change
    create_table :event_visitors do |t|
      t.string :name
      t.string :company
      t.string :position
      t.string :department
      t.string :mobile_phone
      t.string :email

      t.timestamps null: false
    end
  end
end
