class CountryGeoGroup < ActiveRecord::Base
  belongs_to :country
  belongs_to :geo_group
end
