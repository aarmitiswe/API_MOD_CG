class AddNotificationFlag < ActiveRecord::Migration
  def change
    add_column :jobs, :notifed, :boolean , default: false
  end
end
