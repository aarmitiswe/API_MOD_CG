class CreateJobGeoGroups < ActiveRecord::Migration
  def change
    create_table :job_geo_groups do |t|
      t.references :job, index: true
      t.references :geo_group, index: true

      t.timestamps null: false
    end
    add_foreign_key :job_geo_groups, :jobs
    add_foreign_key :job_geo_groups, :geo_groups
  end
end
