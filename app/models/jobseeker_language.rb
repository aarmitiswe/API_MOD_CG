class JobseekerLanguage < ActiveRecord::Base

  belongs_to :jobseeker
  belongs_to :language

  # validates_uniqueness_of :jobseeker_id, scope: :language_id
  # validates_presence_of :jobseeker_id, :language_id
end
