class AddTwitterUrlToJobseeker < ActiveRecord::Migration
  def change
    add_column :jobseekers, :twitter_page_url, :string
  end
end
