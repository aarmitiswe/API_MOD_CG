class EvaluationAnswerSerializer < ActiveModel::Serializer
  attributes :id, :answer
  has_one :evaluation_question
end
