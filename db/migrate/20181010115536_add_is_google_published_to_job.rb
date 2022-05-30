class AddIsGooglePublishedToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :is_goolge_published, :boolean, default: false
  end
end
