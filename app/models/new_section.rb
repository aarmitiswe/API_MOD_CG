class NewSection < ActiveRecord::Base
 include Pagination
  belongs_to :department
  belongs_to :unit
  validates :name, uniqueness: true
end
