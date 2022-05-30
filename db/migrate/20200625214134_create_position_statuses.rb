class CreatePositionStatuses < ActiveRecord::Migration
  def change
    create_table :position_statuses do |t|
      t.string :name
      t.string :ar_name
    end
  end
end
