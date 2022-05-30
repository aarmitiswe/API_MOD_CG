class JobCertificate < ActiveRecord::Base
  belongs_to :job
  belongs_to :certificate
end
