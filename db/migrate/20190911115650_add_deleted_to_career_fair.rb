class AddDeletedToCareerFair < ActiveRecord::Migration
  def change
    add_column :career_fairs, :deleted, :boolean, default: false
  end
end
