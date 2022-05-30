class University < ActiveRecord::Base
  include Pagination

  belongs_to :country
end
