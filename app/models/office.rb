class Office < ActiveRecord::Base
  include Pagination
  validates :name, uniqueness: true
  belongs_to :company
  belongs_to :country
  belongs_to :city
end
