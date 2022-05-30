class Skill < ActiveRecord::Base
  include Pagination

  has_many :jobseeker_skills, dependent: :destroy
  has_many :jobseekers, through: :jobseeker_skills

  validates :name, presence: true
  #validates_uniqueness_of :name, case_sensitive: false
end
