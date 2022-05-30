class JobHistory < ActiveRecord::Base
    self.table_name = 'job_history'

    belongs_to :job
    belongs_to :user
end
