class JobseekerFolder < ActiveRecord::Base
  include Pagination

  belongs_to :jobseeker
  has_one :user, through: :jobseeker
  belongs_to :folder


  validates_uniqueness_of :jobseeker_id, scope: :folder_id
  validates_presence_of :jobseeker_id, :folder_id
end
