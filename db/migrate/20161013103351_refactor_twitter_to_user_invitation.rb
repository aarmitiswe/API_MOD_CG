class RefactorTwitterToUserInvitation < ActiveRecord::Migration
  def change
    add_column :user_invitations, :twitter_contacts, :string, default: [], array: true
    remove_column :user_invitations, :twitter_key, :string
    remove_column :user_invitations, :twitter_secret, :string
  end
end
