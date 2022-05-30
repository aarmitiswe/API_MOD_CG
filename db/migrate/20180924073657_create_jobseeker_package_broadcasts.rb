class CreateJobseekerPackageBroadcasts < ActiveRecord::Migration
  def change
    create_table :jobseeker_package_broadcasts do |t|
      t.references :jobseeker, index: true, foreign_key: :jobseeker_id
      t.references :package_broadcast, index: true, foreign_key: :package_broadcast_id

      t.timestamps null: false
    end
  end
end
