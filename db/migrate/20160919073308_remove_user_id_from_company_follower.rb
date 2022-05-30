class RemoveUserIdFromCompanyFollower < ActiveRecord::Migration
  def change
    remove_column :company_followers, :user_id, :integer
  end
end
