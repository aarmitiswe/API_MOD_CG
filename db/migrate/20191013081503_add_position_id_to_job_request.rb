class AddPositionIdToJobRequest < ActiveRecord::Migration
  def change
    add_column :job_requests, :position_id, :string
  end
end
