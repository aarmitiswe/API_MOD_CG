class JobLanguage < ActiveRecord::Base
  belongs_to :job
  belongs_to :language

  # validates_uniqueness_of :job_id, scope: :language_id
  # validates_presence_of :job_id, :language_id
end
