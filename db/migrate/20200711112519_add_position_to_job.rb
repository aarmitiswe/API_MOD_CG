class AddPositionToJob < ActiveRecord::Migration
  def change
    add_reference :jobs, :position, index: true, foreign_key: :position_id
  end
end
