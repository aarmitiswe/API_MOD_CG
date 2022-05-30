class CreateGeoGroups < ActiveRecord::Migration
  def change
    create_table :geo_groups do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
