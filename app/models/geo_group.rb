class GeoGroup < ActiveRecord::Base
  has_many :country_geo_groups
  has_many :countries, through: :country_geo_groups
  has_many :job_geo_groups
  has_many :jobs, through: :job_geo_groups
end
