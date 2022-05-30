class CreateUserInvitations < ActiveRecord::Migration
  def change
    create_table :user_invitations do |t|
      t.string :twitter_key
      t.string :twitter_secret
      t.references :user, index: true, foreign_key: :user_id

      t.timestamps null: false
    end
  end
end
