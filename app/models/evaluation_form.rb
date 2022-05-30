class EvaluationForm < ActiveRecord::Base
  has_many :evaluation_questions
  has_many :evaluation_submits

  has_many :evaluation_submit_requisitions, dependent: :destroy
end
