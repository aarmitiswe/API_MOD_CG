class PollAnswerSerializer < ActiveModel::Serializer
  attributes :id, :answer, :percentage_vote
end
