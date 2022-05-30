class Grade < ActiveRecord::Base
  include Pagination

  ASSESSOR_GRADE_NAMES = ['Level 2', 'Level 3', 'Level 4', 'Grade 2', 'Grade 3', 'Grade 4']

  belongs_to :company
  validates :name, uniqueness: true

  scope :assessor_grades, -> { where(name: ASSESSOR_GRADE_NAMES) }
end
