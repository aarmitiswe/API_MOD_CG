class CompanySize < ActiveRecord::Base
  scope :active, -> {where(active: true, deleted: false)}
  scope :non_active, -> {where(active: false)}
end
