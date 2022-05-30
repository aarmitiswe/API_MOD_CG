require 'active_support/concern'

module FormatDurationDate
  extend ActiveSupport::Concern

  included do
    def subtract_to_years_months
      start_date = self.from
      end_date = self.to
      # return nil if start_date.nil?
      end_date ||= Date.today
      start_date ||= Date.today
      subtract = end_date - start_date
      years = subtract.to_i / 365
      months = ((subtract - (years * 365)) / 30).round
      if months == 12
        years += 1
        months = 0
      end

      if years > 0 && months > 0
        "#{years} #{years == 1 ? 'Year':'Years' } #{months} #{months == 1 ? 'Month':'Months' }"
      elsif months > 0
        "#{months} #{months == 1 ? 'Month':'Months' }"
      else
        "#{years} #{years == 1 ? 'Year':'Years' }"
      end
    end

    def get_month_year
      start_date = self.from
      end_date = self.to
      return "" if start_date.nil?
      end_date ? "#{start_date.strftime('%b %y')}-#{end_date.strftime('%b %y')}" : "#{start_date.strftime('%b %y')}-Present"
    end


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