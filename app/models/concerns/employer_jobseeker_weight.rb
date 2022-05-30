require 'active_support/concern'

module EmployerJobseekerWeight
  extend ActiveSupport::Concern

  included do
    EMPLOYER_WEIGHT = 10
    JOBSEEKER_WEIGHT = 1

    class << self
      # object_owner .. Job Or JobseekerCertificate
      # associate_name .. skills certificates
      def reduce_weight object_owner, associate_name
        reduce_val = object_owner.class.name == "Job" ? 10 : 1

        object_owner.send(associate_name).map{ |record| record.update_attribute(:weight, record.weight - reduce_val) if record.weight >= reduce_val}
      end
    end
  end
end