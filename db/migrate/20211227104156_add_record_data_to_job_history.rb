class AddRecordDataToJobHistory < ActiveRecord::Migration
  def change
    add_column :job_history, :record_data, :jsonb
  end
end
