class JobBenefit < ActiveRecord::Base
  belongs_to :job
  belongs_to :benefit
end
