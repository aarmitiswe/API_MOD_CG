class RemoveNotificationFromUser < ActiveRecord::Migration
  def change
    remove_reference :users, :notification, index: true, foreign_key: :notification_id
  end
end
