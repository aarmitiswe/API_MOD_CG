class Notification < ActiveRecord::Base

  belongs_to :user, class_name: 'User', foreign_key: 'user_id', dependent: :destroy

  scope :none_notification_jobs, -> { where(job: 0) }
  scope :daily_notification_jobs, -> { where(job: 1) }
  scope :weekly_notification_jobs, -> { where(job: 2) }
  scope :monthly_notification_jobs, -> { where(job: 3) }

  scope :none_notification_polls, -> { where(poll_question: 0) }
  scope :daily_notification_polls, -> { where(poll_question: 1) }
  scope :weekly_notification_polls, -> { where(poll_question: 2) }
  scope :monthly_notification_polls, -> { where(poll_question: 3) }

  scope :none_notification_blogs, -> { where(blog: 0) }
  scope :daily_notification_blogs, -> { where(blog: 1) }
  scope :weekly_notification_blogs, -> { where(blog: 2) }
  scope :monthly_notification_blogs, -> { where(blog: 3) }

  scope :none_notification_candidates, -> { where(candidate: 0) }
  scope :daily_notification_candidates, -> { where(candidate: 1) }
  scope :weekly_notification_candidates, -> { where(candidate: 2) }
  scope :monthly_notification_candidates, -> { where(candidate: 3) }

  def jobseeker
    if self.user.is_jobseeker?
      return self.user.jobseeker
    else
      return nil
    end
  end
end
