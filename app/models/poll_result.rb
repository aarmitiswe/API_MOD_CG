class PollResult < ActiveRecord::Base
  belongs_to :user
  belongs_to :poll_answer
  delegate :poll_question, to: :poll_answer

  validates :poll_answer_id, uniqueness: {scope: :user_id}

  class << self
    # This method to allow user to vote on question.
    # Validates duplicate votes & active question & user permission & correct answer
    def validate_voting user, poll_question, selected_answers_ids
      err_msg = ""
      err_msg = "This question is already answered by this user" unless
          PollResult.where(user_id: user.id, poll_answer_id: poll_question.poll_answer_ids).blank?

      err_msg = "This user hasn't permission to vote this question" unless poll_question.allow_to_vote_by?(user)

      err_msg = "Should be active to answer" unless poll_question.active?
      
      err_msg = "Answers not belong to this question" unless
          (selected_answers_ids - poll_question.poll_answer_ids).empty?

      poll_question.errors[:base] << err_msg unless err_msg.blank?
      poll_question
    end

    # This method to add PollResult
    def vote user, poll_question, selected_answers_ids
      selected_answers_ids = selected_answers_ids.uniq
      poll_question = validate_voting user, poll_question, selected_answers_ids

      return poll_question unless poll_question.errors.blank?

      if poll_question.multiple_selection?
        selected_answers_ids.each do |poll_answer_id|
          PollResult.create(user_id: user.id, poll_answer_id: poll_answer_id)
        end
      else
        PollResult.create(user_id: user.id, poll_answer_id: selected_answers_ids[0])
      end
      poll_question
    end
  end
end
