class AddNotificationToUser < ActiveRecord::Migration
  def change
    add_reference :users, :notification, index: true, foreign_key: :notification_id
  end
end
