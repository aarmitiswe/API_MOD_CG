class AddWeightToTags < ActiveRecord::Migration
  def change
    add_column :tags, :weight, :integer, default: 0
  end
end
