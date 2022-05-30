class EvaluationAnswer < ActiveRecord::Base
  belongs_to :evaluation_submit
  belongs_to :evaluation_question

  ANSWERS_MEANING = {
      "E" => "Excellent",
      "G" => "Good",
      "F" => "Fair",
      "P" => "Poor"
  }

  def answer_text
    ANSWERS_MEANING[self.answer] || self.answer
  end
end
