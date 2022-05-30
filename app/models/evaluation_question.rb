class EvaluationQuestion < ActiveRecord::Base
  belongs_to :evaluation_form
  has_many :evaluation_answers
end
