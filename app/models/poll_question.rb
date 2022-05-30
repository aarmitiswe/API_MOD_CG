class PollQuestion < ActiveRecord::Base
  include Pagination

  POLL_TYPES = %w(jobseeker_only employer_only both)

  has_many :poll_answers, dependent: :destroy
  accepts_nested_attributes_for :poll_answers

  has_many :poll_results, through: :poll_answers

  scope :unexpired, -> { where("expire_at > ? OR expire_at IS ?", Date.today, nil) }
  scope :expired, -> { where("expire_at < ?", Date.today) }

  scope :active, -> { where(active: true).unexpired }

  scope :for_jobseeker, -> { where(poll_type: ["jobseeker_only", "both"]) }
  scope :for_employer, -> { where(poll_type: ["employer_only", "both"]) }

  scope :for_user, -> (user) { where(poll_type: user.is_jobseeker? ? "jobseeker_only" : "employer_only") }

  scope :answered_by, -> (user) { joins(:poll_results).where("poll_results.user_id" => user.id) }
  scope :not_answered_by, -> (user) { joins(:poll_results).where("poll_results.user_id" => user.id) }

  validates_presence_of :question, :poll_type
  validates :poll_type, inclusion: { in: PollQuestion::POLL_TYPES }

  def allow_to_vote_by? user
    user.is_jobseeker? && %w(jobseeker_only both).include?(self.poll_type) ||
    user.is_employer? && %w(employer_only both).include?(self.poll_type)
  end

  def is_answered_by_user user
    !user.nil? && !PollResult.find_by(user_id: user.id, poll_answer_id: self.poll_answer_ids).nil?
  end

  def calculate_vote_percentage
    answers = self.poll_answers
    percentage_sum = 0
    answers[1..-1].each do |answer|
      answers_count = PollResult.where(poll_answer_id: answer.id).count
      if answers_count == 0
        answer.percentage_vote = 0
      else
        answer.percentage_vote =  (answers_count * 100 / self.poll_results.count).round
        percentage_sum += answer.percentage_vote
      end
    end

    answers[0].percentage_vote = 100 - percentage_sum
  end
end
