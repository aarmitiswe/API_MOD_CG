class RemoveNationalityIdFromJobs < ActiveRecord::Migration
  def change
    remove_column :jobs, :nationality_id
  end
end
