class AddLatestChangorUserToJob < ActiveRecord::Migration
  def change
    add_reference :jobs, :latest_changor_user
    add_foreign_key :jobs, :users, column: :latest_changor_user_id
  end
end
