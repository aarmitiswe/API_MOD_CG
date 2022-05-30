class Language < ActiveRecord::Base
  include Pagination
  validates :name, presence: true
end
