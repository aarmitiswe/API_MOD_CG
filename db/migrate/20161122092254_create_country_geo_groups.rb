class CreateCountryGeoGroups < ActiveRecord::Migration
  def change
    create_table :country_geo_groups do |t|
      t.references :country, index: true
      t.references :geo_group, index: true

      t.timestamps null: false
    end
    add_foreign_key :country_geo_groups, :countries
    add_foreign_key :country_geo_groups, :geo_groups
  end
end
