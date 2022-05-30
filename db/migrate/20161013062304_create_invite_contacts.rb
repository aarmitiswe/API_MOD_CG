class CreateInviteContacts < ActiveRecord::Migration
  def change
    create_table :invite_contacts do |t|
      t.string :contacts, default: [], array: true

      t.timestamps null: false
    end
  end
end
