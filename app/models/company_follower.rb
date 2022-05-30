class CompanyFollower < ActiveRecord::Base
  belongs_to :jobseeker
  belongs_to :company

  validates :company_id, uniqueness: {scope: :jobseeker_id}

  scope :daily, -> { where("created_at > ?", 1.week.ago).group("DATE_TRUNC('day', created_at)").count }
  scope :weekly, -> { where("created_at > ?", 2.month.ago).group("DATE_TRUNC('week', created_at)").count }
  scope :monthly, -> { where("created_at > ?", 1.year.ago).group("DATE_TRUNC('month', created_at)").count }

end
