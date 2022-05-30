class EvaluationSubmitSerializer < ActiveModel::Serializer
  attributes :id, :comment, :total_score, :created_at, :interviewer_full_name, :interviewer_position,
             :interviewer_id, :updated_at, :status

  has_many :evaluation_answers
  has_many :evaluation_submit_requisitions
  has_one :evaluation_form

  def interviewer_full_name
    "#{object.user.first_name} #{object.user.last_name}"
  end

  def interviewer_position
    object.user.role
  end

  def interviewer_id
    object.user.id
  end

end
