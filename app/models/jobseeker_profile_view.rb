class JobseekerProfileView < ActiveRecord::Base
  include Pagination
  belongs_to :company_user
  has_one :company, through: :company_user
  belongs_to :jobseeker

  scope :group_by_jobseekers, -> { group(:jobseeker_id).count }
  scope :daily, -> { where("created_at > ?", 1.week.ago).group("DATE_TRUNC('day', created_at)").count }
  scope :weekly, -> { where("created_at > ?", 2.month.ago).group("DATE_TRUNC('week', created_at)").count }
  scope :monthly, -> { where("created_at > ?", 1.year.ago).group("DATE_TRUNC('month', created_at)").count }

  validate :uniq_viewer_per_day

  def uniq_viewer_per_day
    unless JobseekerProfileView.where(jobseeker_id: self.jobseeker_id,
                               company_id: self.company_id,
                               created_at: (self.created_at || DateTime.now).beginning_of_day..(self.created_at || DateTime.now).end_of_day).blank?
      self.errors.add(:jobseeker_id, " viewed by #{self.company_id} in #{self.created_at}")
    end
  end
end
