class Tag < ActiveRecord::Base
  include Pagination
  belongs_to :tag_type

  validates_uniqueness_of :name, scope: :tag_type_id, case_sensitive: false
  validates :name, presence: true
end
