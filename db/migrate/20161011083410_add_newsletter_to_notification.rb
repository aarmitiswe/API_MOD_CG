class AddNewsletterToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :newsletter, :boolean, default: true
  end
end
