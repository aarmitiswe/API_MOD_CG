class AddWeightToSkills < ActiveRecord::Migration
  def change
    add_column :skills, :weight, :integer, default: 0
  end
end
