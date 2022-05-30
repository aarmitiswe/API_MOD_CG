require 'active_support/concern'

module MatchingPercentageAttributes
  extend ActiveSupport::Concern

  included do

    ATTR_WEIGHT = {
        country: Math.sqrt(60),
        city: Math.sqrt(10),
        sector: Math.sqrt(60),
        # functional: Math.sqrt(60),
        # position: Math.sqrt(60),
        # years_experience: Math.sqrt(60),
        # job_experience_level: Math.sqrt(10),
        # job_education: Math.sqrt(50),
        # expected_salary: Math.sqrt(60),
        # job_type: Math.sqrt(2),
        # skills: Math.sqrt(40),
        # nationality: Math.sqrt(20),
        # marital_status: Math.sqrt(2.5),
        # visa_status: Math.sqrt(2.75),
        # driving_license: Math.sqrt(2.5),
        # languages: Math.sqrt(2.5),
        # join_date: Math.sqrt(2.5),
        # certificates: Math.sqrt(1.2),
        # age: Math.sqrt(5),
        # gender: Math.sqrt(2.5),
        # error: 14.97
    }
  end
end