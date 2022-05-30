class SavedJob < ActiveRecord::Base
  include Pagination

  belongs_to :jobseeker
  belongs_to :job

  validates :job_id, uniqueness: {scope: :jobseeker_id}
end
