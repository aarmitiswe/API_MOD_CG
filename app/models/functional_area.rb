class FunctionalArea < ActiveRecord::Base
  include Pagination

  validates_presence_of :area
end
