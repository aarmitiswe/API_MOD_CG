class PollQuestionSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id, :question, :poll_type, :multiple_selection, :active, :start_at, :expire_at,
             :is_answered_by_current_user

  has_many :poll_answers

  def is_answered_by_current_user
    object.is_answered_by_user current_user
  end
end
