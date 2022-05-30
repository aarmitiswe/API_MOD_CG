class AddContactsToUserInvitation < ActiveRecord::Migration
  def change
    add_column :user_invitations, :gmail_contacts, :string, default: [], array: true
    add_column :user_invitations, :yahoo_contacts, :string, default: [], array: true
    add_column :user_invitations, :outlook_contacts, :string, default: [], array: true
  end
end
