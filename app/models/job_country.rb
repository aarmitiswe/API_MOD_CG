class JobCountry < ActiveRecord::Base
  belongs_to :job
  belongs_to :country
end
