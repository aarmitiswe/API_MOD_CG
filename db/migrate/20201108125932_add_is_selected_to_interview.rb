class AddIsSelectedToInterview < ActiveRecord::Migration
  def change
    add_column :interviews, :is_selected, :boolean, default: false
  end
end
