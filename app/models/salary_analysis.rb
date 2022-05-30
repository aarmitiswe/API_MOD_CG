class SalaryAnalysis < ActiveRecord::Base
  belongs_to :job_application
  has_many :offer_requisitions, dependent: :destroy

  before_create :set_level
  after_create :send_notification

  def set_level
    self.level = self.job_application.offer_analyses.count + 1
  end

  def annual_incentives
    self.ticket_allowance + self.education_allowance + self.incentives
  end

  def total_annual
    (self.monthly_salary * 12.0) + self.annual_incentives
  end

  def all_offer_approved?
    offer_approvers_count = 3
    self.offer_requisitions.count == offer_approvers_count && self.offer_requisitions.approved.count  == offer_approvers_count && self.offer_requisitions.map(&:status).all?{|ele| ele == 'approved'}
  end

  def send_notification
  #   Asking General Manager of HR to Approve Salary Analysis
  #   Asking Deputy Minister to Approve Salary Analysis
  #   Approving Job Offer Analysis to all recruiters
  end
end
