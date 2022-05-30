class JobGeoGroup < ActiveRecord::Base
  belongs_to :job
  belongs_to :geo_group
end
