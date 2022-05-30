class AddIsInternalHiringToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :is_internal_hiring, :boolean, default: false
  end
end
