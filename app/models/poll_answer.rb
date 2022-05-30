class PollAnswer < ActiveRecord::Base
  belongs_to :poll_question
  has_many :poll_results

  attr_accessor :percentage_vote

  validates_presence_of :answer

  # def percentage_vote
  #   answers_count = PollResult.where(poll_answer_id: self.poll_question.poll_answer_ids).count
  #   return 0 if answers_count == 0
  #   (self.poll_results.count * 100 / answers_count).round
  # end
end
