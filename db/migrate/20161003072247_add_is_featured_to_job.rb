class AddIsFeaturedToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :is_featured, :boolean, default: false
  end
end
