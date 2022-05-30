class AddNotifiedField < ActiveRecord::Migration
  def change
    remove_column :jobs , :notifed
    add_column :jobs , :notified , :boolean , default: false
  end
end
