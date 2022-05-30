class AddIsAutoCompleteToSkill < ActiveRecord::Migration
  def change
    add_column :skills, :is_auto_complete, :boolean, default: false
  end
end
