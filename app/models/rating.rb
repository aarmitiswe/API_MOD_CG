class Rating < ActiveRecord::Base

  belongs_to :creator, class_name: User, foreign_key: 'creator_id'
  belongs_to :jobseeker

  validates :rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5,  only_integer: true }
end
