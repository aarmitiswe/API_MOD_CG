class UnitOld < ActiveRecord::Base
  include Pagination
  belongs_to :department
  validates :name, uniqueness: true
end
