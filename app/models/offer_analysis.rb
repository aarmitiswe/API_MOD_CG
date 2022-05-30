class OfferAnalysis < ActiveRecord::Base
  include OfferRequisitionBuilder

  belongs_to :job_application
  belongs_to :user
  has_many :offer_requisitions, dependent: :destroy

  before_create :set_percentage
  # before_create :set_level

  def salary_analysis
    # self.job_application.salary_analyses.order(:level).where(level: self.level).last
    self.job_application.salary_analyses.find_by(level: self.level)
  end

  def self.update_calculated_attributes
    OfferAnalysis.all.each{|o| o.set_percentage; o.save!}
  end

  def set_percentage
    self.set_level
    self.percentage_increase = (self.monthly_salary / self.salary_analysis.monthly_salary - 1) * 100.0
  end

  def set_level
    self.level = self.job_application.offer_analyses.count + 1
  end

  def total_annual
    self.monthly_salary * 12.0
  end
end
