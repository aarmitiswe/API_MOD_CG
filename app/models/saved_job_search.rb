class SavedJobSearch < ActiveRecord::Base
  include Pagination
  
  belongs_to :jobseeker
  belongs_to :alert_type

  validates_presence_of :jobseeker, :alert_type, :title
end
